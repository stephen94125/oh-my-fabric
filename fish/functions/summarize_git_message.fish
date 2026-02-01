function summarize_git_message --description "Generate semantic git commit message using Fabric with history context"
    # 1. Check if inside a Git project
    if not git rev-parse --is-inside-work-tree >/dev/null 2>&1
        echo "❌ Error: Not inside a git repository."
        return 1
    end

    # 2. Check if there are staged changes
    git diff --cached --quiet
    if test $status -eq 0
        echo "⚠️  Warning: No staged changes found. Please 'git add' files first."
        return 1
    end

    # 3. Set default language (if LANGUAGE_OUTPUT is not set externally, default to en-US)
    set -q LANGUAGE_OUTPUT; or set -l LANGUAGE_OUTPUT "en-US"

    echo -e "⏳ Generating commit message with Fabric ($LANGUAGE_OUTPUT)...\n\n"

    # 4. Start assembling Prompt Context
    begin
        # --- Context A: Historical Style Reference (Few-Shot) ---
        echo "### REFERENCE: Last 10 Commit Messages (For Style Imitation)"
        # Only capture the Subject, remove noise, let AI focus on learning the format (e.g., chore:, feat:, etc.)
        git log -n 10 --pretty=format:"%s" 2>/dev/null
        echo -e "\n"

        # --- Context B: User Intent (Optional) ---
        if count $argv > /dev/null
            echo "### USER INTENT (Highest Priority)"
            echo "$argv"
            echo ""
        end

        # --- Context C: Actual Changes (Diff) ---
        echo "### INPUT: Git Diff (Staged Changes)"
        git diff --cached
    end | begin
        # --- Pipeline Stage: Fabric Processing & Clipboard ---
        
        # 1. 決定剪貼簿指令 (Strategy Pattern)
        set -l clip_cmd
        if type -q wl-copy
            set clip_cmd wl-copy
        else if type -q pbcopy
            set clip_cmd pbcopy
        else if type -q xclip
            set clip_cmd xclip -selection clipboard
        else
            echo "❌ Error: No clipboard tool found (install wl-clipboard)." >&2
            return 1
        end

        # 2. 執行 Fabric 並導入剪貼簿 (Single Pipeline)
        # 注意：env 變數設定要放在 fabric 前面
        env LANGUAGE_OUTPUT=$LANGUAGE_OUTPUT fabric -p format_git_commit_message | tee /dev/tty | $clip_cmd
    end

    echo -e "\n\n✅ Commit message generated! Result copied to clipboard."
end
