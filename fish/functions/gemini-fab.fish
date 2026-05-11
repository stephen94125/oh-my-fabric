if not set -q GEMINI_MODEL
    set -Ux GEMINI_MODEL 'gemini-3.1-pro-preview'
end

function gemini-fab --description "Wrapper for fabric patterns with gemini"
    # 1. 解析參數 (-p pattern_name)
    # 格式: gemini-fab -p <pattern>
    argparse 'p/pattern=' -- $argv
    or return 1

    # 檢查是否提供了 pattern
    if not set -q _flag_pattern
        echo "錯誤: 請指定 Pattern，例如: ... | gemini-fab -p summarize" >&2
        return 1
    end

    # 2. 設定路徑
    set -l pattern_dir ~/.config/fabric/patterns/$_flag_pattern
    set -l system_md_path "$pattern_dir/system.md"

    if not test -f "$system_md_path"
        echo "錯誤: 找不到 Pattern: $system_md_path" >&2
        return 1
    end

    # 3. 準備 System Prompt (包含語言注入)
    set -l tmp_file (mktemp)
    cat "$system_md_path" > $tmp_file
    echo -e "\n\nIMPORTANT: First, execute the instructions provided in this prompt using the user's input. Second, ensure your entire final response, including any section headers or titles generated as part of executing the instructions, is written ONLY in the \"$LANGUAGE_OUTPUT\" language." >> $tmp_file

    # 4. 設定環境變數
    set -lx GEMINI_SYSTEM_MD $tmp_file

    # --- [新增] 狀態提示與模型判斷 ---
    set -l color_green (set_color green)
    set -l color_reset (set_color normal)
    echo -e "$color_green🤖 Gemini-Fab:$color_reset '$_flag_pattern' using '$GEMINI_MODEL'\n" >&2
    gemini -m "$GEMINI_MODEL"

    # 6. 清理
    rm -f $tmp_file
end

