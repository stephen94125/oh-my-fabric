function distill_dir --description "Batch distill markdown files from Source to Target"
    # ==========================================
    # DISTILL DIR: Source -> Target
    # ==========================================

    # --- Configuration ---
    set PATTERN "extract_by_pareto"
    set ENGINE "gemini-fab"
    
    # --- Arguments Check ---
    if test (count $argv) -lt 2
        set_color red; echo "❌ [ERROR] 參數不足"; set_color normal
        echo "   Usage: distill_dir <source_folder> <destination_folder>"
        return 1
    end

    set source_dir (realpath -m $argv[1])
    set target_dir (realpath -m $argv[2])

    # --- Safety Checks ---
    if not type -q $ENGINE
        set_color red; echo "❌ [ERROR] Engine not found in PATH: $ENGINE"; set_color normal
        return 1
    end

    if not test -d "$source_dir"
        set_color red; echo "❌ [ERROR] 來源目錄不存在: $source_dir"; set_color normal
        return 1
    end

    if test "$source_dir" = "$target_dir"
        set_color red; echo "⛔️ [DANGER] 來源與目的目錄不能相同！"; set_color normal
        return 1
    end

    # 建立輸出目錄
    if not test -d "$target_dir"
        mkdir -p "$target_dir"
    end

    # 搜尋檔案 (使用 ls -v 確保章節順序: 1, 2, 10...)
    # 這裡指向 source_dir 裡面的 .md
    # set files (ls -v "$source_dir"/*.md 2>/dev/null)
    set files "$source_dir"/*.md
    set total_files (count $files)
    
    if test $total_files -eq 0
        set_color red; echo "⚠️  No markdown files found in source."; set_color normal
        return 1
    end

    # --- UI Setup ---
    tput civis
    clear
    set_color -o purple; echo "🧪 DISTILLING BATCH (Source -> Target)"; set_color normal
    echo "──────────────────────────────────────────────"
    set_color cyan;  echo " 📂 Source :: $source_dir"; set_color normal
    set_color blue;  echo " 🎯 Target :: $target_dir"; set_color normal
    set_color yellow; echo " 🧠 Pattern:: $PATTERN"; set_color normal
    echo "──────────────────────────────────────────────"
    echo ""

    set start_time (date +%s)
    set current_idx 0
    set processed_count 0

    # --- Loop ---
    for file_path in $files
        set current_idx (math $current_idx + 1)
        set percent (math -s0 "($current_idx / $total_files) * 100")
        
        # 取得純檔名 (不含路徑)
        set filename (basename "$file_path")
        set out_file "$target_dir/$filename"

        # 進度條計算
        set bar_width 20
        set filled_width (math -s0 "($percent / 100) * $bar_width")
        set empty_width (math $bar_width - $filled_width)
        set bar_filled (string repeat -n $filled_width "█")
        set bar_empty (string repeat -n $empty_width "░")

        # 動畫顯示
        echo -ne "\r\033[K"
        
        set_color green
        # 顯示處理中的檔名
        printf " [%3d%%] %s%s ⚡️ %s" $percent $bar_filled $bar_empty $filename
        set_color normal
        
        # --- 核心邏輯 ---
        true > "$out_file"
        
        # 2. Fabric 處理 (無 Context 注入)
        cat "$file_path" | $ENGINE -p $PATTERN >> "$out_file"
        
        set processed_count (math $processed_count + 1)
    end

    set end_time (date +%s)
    set duration (math $end_time - $start_time)
    
    tput cnorm 
    
    echo ""
    echo "──────────────────────────────────────────────"
    set_color -o green; echo "✅ BATCH COMPLETE"; set_color normal
    set_color white
    echo "   📂 From: $source_dir"
    echo "   📂 To  : $target_dir"
    echo "   📄 Files: $processed_count"
    echo "   ⏱️  Time : $duration seconds"
    set_color normal
    echo ""
end

