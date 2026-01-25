# NAME

task - A command line todo manager.

# SYNOPSIS

**task \<filter\> \<command\> [ \<mods\> | \<args\> ]**
**task --version**

# DESCRIPTION

Taskwarrior is a command line todo list manager. It maintains a list of tasks allowing addition, removal, and manipulation. It supports due dates, priorities, tags, project groups, and complex filtering.

# FILTER

Selects tasks for commands. Implicit `and` operator; `or`/`xor` require parentheses.

*   **Syntax**: `task project:Home +weekend garden list`
*   **Shortcuts**: `garden` equates to `description.contains:garden`.
*   **Empty Filter**: Applies to all tasks (requires confirmation).
*   **IDs/UUIDs**: `task 1 2-5 modify pri:H`.

# MODIFICATIONS

Changes applied to selected tasks.
*   **Syntax**: `task <filter> <command> <mods>`
*   **Examples**: `project:Home`, `+tag`, `/from/to/` (replace first), `/from/to/g` (replace all).

# SUBCOMMANDS

## READ SUBCOMMANDS

*   **task --version**: Verify version.
*   **task \<filter\>**: Runs default command (usually `list`).
*   **active / completed / waiting / blocked / blocking / recurring**: Show tasks by status.
*   **all**: Show all tasks, including parents.
*   **burndown.{daily,weekly,monthly}**: Graphical burndown charts.
*   **calendar [due|month year] [y]**: Text-based calendar.
*   **colors / columns / commands**: List supported configurations.
*   **count**: Count matching tasks.
*   **export**: Export to JSON.
*   **ghistory.{annual,monthly,weekly,daily}**: Graphical history charts.
*   **history.{annual,monthly,weekly,daily}**: Text history reports.
*   **ids / uuids**: List IDs or UUIDs.
*   **information**: Full metadata and change history.
*   **list / long / ls / minimal**: Standard task listings.
*   **newest / oldest**: Sort by creation date.
*   **next**: Most urgent tasks.
*   **ready**: Actionable tasks.
*   **overdue**: Incomplete tasks past due date.
*   **projects**: List project names and task counts.
*   **stats / summary**: Aggregated status reports.
*   **tags / udas**: List used tags or defined UDAs.
*   **timesheet [weeks]**: Weekly report.
*   **unblocked**: Actionable tasks not blocked by others.

## WRITE SUBCOMMANDS

*   **add \<mods\>**: Create new task.
*   **annotate \<mods\>**: Add note to task.
*   **append / prepend \<mods\>**: Modify description text.
*   **delete \<mods\>**: Mark deleted.
*   **denotate \<mods\>**: Remove annotation.
*   **done \<mods\>**: Mark completed.
*   **duplicate \<mods\>**: Clone task.
*   **edit**: Launch text editor.
*   **import [file]**: Import JSON tasks.
*   **log \<mods\>**: Add already completed task.
*   **modify \<mods\>**: Update existing task.
*   **purge**: Permanently remove deleted tasks.
*   **start / stop \<mods\>**: Toggle active state.

## MISCELLANEOUS SUBCOMMANDS

*   **calc \<expression\>**: Evaluate algebraic expression.
*   **config [name [value]]**: Set value. If value is empty (''), clears default. If value omitted, removes setting.
*   **context [name | delete | define | list | none | show]**: Manage user-defined contexts (filters applied automatically).
*   **diagnostics**: System info for bug reporting.
*   **execute \<cmd\>**: Run external command.
*   **news**: Release notes.
*   **reports**: List available reports.
*   **show [all | substring]**: Display current settings.
*   **sync**: Synchronize with Taskserver.
*   **undo**: Revert last action.

## HELPER SUBCOMMANDS

Internal commands for shell completion and scripting.
*   `_aliases`, `_columns`, `_commands`, `_config`, `_context`, `_ids`, `_projects`, `_show`, `_tags`, `_udas`, `_unique`, `_urgency`, `_uuids`, `_version`, `_zshcommands`.
*   **_get \<DOM\>**: Extract specific values (e.g., `rc.name`, `system.os`, `<id>.due`).

# ATTRIBUTES AND METADATA

*   **ID**: Volatile index for pending/recurrent tasks.
*   **+tag / -tag**: Add/remove tags.
    *   *Special*: `+nocolor`, `+nonag`, `+nocal`, `+next`.
    *   *Virtual*: `ACTIVE`, `BLOCKED`, `DUE`, `LATEST`, `OVERDUE`, `PENDING`, `READY`, `TODAY`, `WEEK`, etc.
*   **project:\<name\>**: Assign project.
*   **status**: `pending`, `deleted`, `completed`, `waiting`, `recurring`.
*   **priority**: `H`, `M`, `L`, or none.
*   **due**: Due date.
*   **recur**: Frequency.
*   **scheduled**: Start date for actionability.
*   **until**: Expiration date.
*   **wait**: Hide until date.
*   **limit**: Row count or `page`.
*   **depends**: Comma-separated IDs.
*   **entry / modified**: Creation/modification dates.

# ATTRIBUTE MODIFIERS

Refines filters. Syntax: `attribute.modifier:value`.

*   **Comparison**: `before` (`under`, `below`), `after` (`over`, `above`), `by` (inclusive).
*   **Existence**: `none` (no value), `any` (has value).
*   **Matching**: `is` (`equals`), `isnt` (`not`), `has` (`contains`), `hasnt`.
*   **String**: `startswith` (`left`), `endswith` (`right`), `word`, `noword`.

# EXPRESSIONS AND OPERATORS

*   **Logical**: `and`, `or`, `xor`, `!`. Parentheses required for non-`and` logic.
*   **Relational**: `<`, `<=`, `=`, `==`, `!=`, `!==`, `>=`, `>`.

# SPECIFYING DATES AND FREQUENCIES

Taskwarrior supports extensive date mathematics. Dates can be exact, relative, or calculated using **Reference Points** (Anchors) combined with **Offsets** (Duration Units).

## Reference Points (Anchors)

These keywords represent specific points in time.

* **Time**: `now`
* **Day**: `today`, `yesterday`, `tomorrow`
* `sod` (Start of Day: 00:00), `eod` (End of Day: 23:59)


* **Week**:
* `sow` (Start of Week), `eow` (End of Week)
* `sowww` (Start of Work Week), `eowww` (End of Work Week)


* **Month**: `som` (Start of Month), `eom` (End of Month)
* **Quarter**: `soq` (Start of Quarter), `eoq` (End of Quarter)
* **Year**: `soy` (Start of Year), `eoy` (End of Year)

## Duration Units (Offsets)

Used to add or subtract time from anchors.

* `y` (years), `m` (months), `w` (weeks), `d` (days)
* `h` (hours), `min` (minutes), `s` (seconds)

## Calculation Examples (Anchor + Offset)

Logic: Start from a reference point and add/subtract precise time units.

* **The 3rd of this month** (Start of Month + 2 days):
`som+2d`
* **March of this year** (Start of Year + 2 months):
`soy+2m`
* **April 15th of this year at 3:20 PM**:
`soy+3m+14d+15h+20min`
*(Logic: Start of Year + 3 full months + 14 full days + 15 hours + 20 minutes)*
* **Friday of next week at 5:00 PM**:
`sow+1w+4d+17h`
* **Three days before the end of the month**:
`eom-3d`
* **Next Monday**:
`sow+1w`


# CONTEXT

User-defined query automatically applied to filter/create commands.
*   **Define**: `task context define home project:Home`
*   **Set**: `task context home`
*   **Clear**: `task context none`
*   **Config**: Stored in `context.<name>.read` and `context.<name>.write`.

# COMMAND ABBREVIATION

Commands may be abbreviated to the shortest unique prefix (e.g., `li` for `list`).

# SPECIFYING DESCRIPTIONS

*   **Escaping**: Use quotes (`"foo bar"`) or escape characters (`foo\ bar`).
*   **Literal**: Use `--` to treat all subsequent arguments as description.

# CONFIGURATION FILE AND OVERRIDE OPTIONS

Default: `~/.taskrc`.
*   **Override File**: `task rc:<path>` or `TASKRC=<path>` env.
*   **Override Setting**: `task rc.<name>:<value>`.
*   **Override Data**: `TASKDATA=/tmp/.task`.

# FILES

*   `~/.taskrc`: User configuration.
*   `~/.task`: Default data directory.
*   `~/.task/taskchampion.sqlite3`: Database file.
