function gemini-fab --description "Wrapper for fabric patterns with gemini"
    # 1. 解析參數 (-p pattern_name)
    # 格式: gemini-fab -p <pattern>
    argparse 'p/pattern=' -- $argv
    or return 1

    # 檢查是否提供了 pattern
    if not set -q _flag_pattern
        echo "錯誤: 請指定 Pattern，例如: gemini-fab -p summarize" >&2
        return 1
    end

    # 2. 讀取 Pipe Input (標準輸入)
    # 如果沒有 pipe input，嘗試讀取參數或報錯
    set -l user_input ""
    if not isatty stdin
        read -z user_input
    else
        echo "錯誤: 請提供 Pipe Input，例如: echo 'text' | gemini-fab -p summarize" >&2
        return 1
    end

    # 3. 設定路徑與檢查檔案
    set -l pattern_dir ~/.config/fabric/patterns/$_flag_pattern
    set -l system_md_path "$pattern_dir/system.md"

    if not test -f "$system_md_path"
        echo "錯誤: 找不到 Pattern 檔案: $system_md_path" >&2
        return 1
    end

    # 4. 建立暫存檔案並組裝 Prompt
    set -l tmp_file (mktemp)
    
    # 寫入原始 system.md
    cat "$system_md_path" > $tmp_file
    
    # 寫入分隔與注入語言指令
    echo -e "\n\n" >> $tmp_file
    echo "IMPORTANT: First, execute the instructions provided in this prompt using the user's input. Second, ensure your entire final response, including any section headers or titles generated as part of executing the instructions, is written ONLY in the \"$LANGUAGE_OUTPUT\" language." >> $tmp_file

    # 5. 執行 gemini 命令
    # 使用 set -lx 將環境變數僅導出給本次執行的子程序
    set -lx GEMINI_SYSTEM_MD $tmp_file
    
    # 這裡依照你的指示，將 pipe input 放入 -p 參數
    # 注意：如果 input 非常巨大，可能會超過 ARG_MAX 限制，但在一般使用場景通常沒問題
    gemini -m gemini-3-flash-preview -p "$user_input"

    # 7. 清理暫存檔
    rm -f $tmp_file
end

