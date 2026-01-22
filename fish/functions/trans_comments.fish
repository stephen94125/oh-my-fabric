function trans_comments --description "Translate code comments with safety checks"
    # 1. Check arguments
    if test (count $argv) -eq 0
        echo "❌ Usage: trans_write_back <filename>"
        return 1
    end

    set -l file_path $argv[1]

    # 2. Check if file exists
    if not test -f "$file_path"
        echo "❌ Error: File '$file_path' not found."
        return 1
    end

    # Get absolute path and directory
    set -l abs_path (realpath $file_path)
    set -l dir_path (dirname $abs_path)
    set -l base_name (basename $abs_path)

    # 3. 🔥 Critical safety check: Check if important data in the staging area will be overwritten
    # git diff --cached --quiet returns exit code 1 if there are differences (something is in the staging area)
    # git diff --quiet returns exit code 1 if the working directory differs from the staging area
    
    # Logic: If (file is staged) AND (staged content != working directory content) -> Dangerous!
    if not git -C "$dir_path" diff --cached --quiet "$base_name"
        # Something is in the staging area. Now check if it matches the working directory?
        if not git -C "$dir_path" diff --quiet "$base_name"
            echo "🛑 STOP! Conflict detected in '$base_name'."
            echo "   - You have STAGED changes (Version A) that differ from WORKING changes (Version B)."
            echo "   - Running this script would DESTROY your staged changes."
            echo "👉 Action: Please 'git commit' your staged changes first, then run this again."
            return 1
        end
    end

    echo "🛡️  Git safety check passed."

    # 4. Normal backup process (for unstaged changes)
    if git -C "$dir_path" rev-parse --is-inside-work-tree >/dev/null 2>&1
        echo "   - Staging current working copy as backup..."
        git -C "$dir_path" add "$base_name"
    else
        echo "   - ⚠️  Not a git repo. Creating .bak instead."
        cp "$file_path" "$file_path.bak"
    end

    echo "🔄 Translating comments..."

    # 5. Execute translation
    cat "$file_path" | fabric -p translate_code_comments > "$file_path.tmp"

    if test $status -eq 0
        mv "$file_path.tmp" "$file_path"
        echo -e "\n✅ Translation applied!"
        echo "👀 Use 'git diff' to review changes."
    else
        rm "$file_path.tmp"
        echo -e "\n❌ Error: Translation failed."
    end
end
