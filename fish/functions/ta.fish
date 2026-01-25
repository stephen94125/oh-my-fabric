function ta --description "Ask Fabric to generate a Taskwarrior command and populate the buffer"
    # 1. Capture all input parameters and combine them into a single string
    set -l input_text (string join " " $argv)

    # 2. Basic validation
    if test -z "$input_text"
        echo "Usage: ta <your natural language task description>"
        return 1
    end

    # 3. Provide a hint, as the LLM takes some time to process (write to stderr to avoid interfering with the buffer)
    echo "🤖 Fabric is thinking..." >&2

    # 4. Call Fabric and trim leading/trailing whitespace
    set -l result (echo "$input_text" | fabric -p "taskwarrior-assistant" | string trim)

    # 5. Check if the returned result is valid (whether it starts with task add)
    if string match -q "task add*" -- $result
        # [Magic Step 1] Replace the current command line buffer content
        commandline -r -- $result

        # [Magic Step 2] Move the cursor
        # The length of "task add " (including quotes) is 10
        # Set cursor position to Index 10, which is right after the first quote
        commandline -C 10
    else
        # If Fabric outputs something unexpected (e.g., API error), display error message
        echo "❌ Error or unexpected output from Fabric:" >&2
        echo "$result" >&2
        return 1
    end
end
