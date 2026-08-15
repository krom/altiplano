# Changelog

All notable changes to this project are documented here.

## [0.6.0]

### Added

- `list_project_users`, to list who has access to a project and their
  permission level.
- `search_tasks`, to filter/search tasks across all projects instead of one.
- `move_task`, to move a task to a different project.
- `bulk_update_tasks`, to apply `done`/`priority` to multiple tasks in one
  call.
- `list_attachments`, to list a task's file attachments.
- `duplicate_task`, to duplicate a task (linked back via a `copiedfrom`
  relation).
- `list_relations`, `add_relation`, `remove_relation`, to manage task
  relations (subtask, blocking, precedes, etc).
- `create_label`, to create a label.
- `list_reactions`, `add_reaction`, `remove_reaction`, for emoji reactions on
  tasks.
- `list_comment_reactions`, `add_comment_reaction`, `remove_comment_reaction`,
  for emoji reactions on comments; `list_comments` now includes each
  comment's reactions inline.
- A Dockerfile for running the server behind `mcpo`.

## [0.5.0]

### Fixed

- `get_task_bucket` returned a false negative for tasks past the first 50 in
  a bucket. It now filters the view tasks request to the target task instead
  of paging through the whole board.
- `list_bucket_tasks` silently truncated buckets larger than 50 tasks. It now
  exposes `page`, `per_page`, and `filter`, and reports `task_count` per
  bucket.
- `list_buckets`' `count` always reported `0`. Counts are now sourced from
  the view tasks endpoint, the only one that populates them.
- `is_default_bucket` in `list_buckets` reported `false` for every bucket
  when `default_bucket_id` is unset (the common case, meaning the leftmost
  bucket). It now falls back to the bucket with the lowest `position`.
- `update_task` and `set_reminders` silently reset every field omitted from
  the request body, since `POST /tasks/{id}` is a full replace upstream, not
  a patch. They now fetch the task first and merge changes into it.

### Added

- `list_kanban_views`, and an optional `view_id` parameter on `list_buckets`,
  `list_bucket_tasks`, and `move_task_to_bucket`, to disambiguate projects
  with more than one kanban view.

## [0.4.0]

### Breaking

- Requires the MCP Python SDK 2.x (`mcp>=2.0.0,<3`). The SDK 1.x line is no
  longer supported.

### Fixed

- The server no longer fails to start with
  `ModuleNotFoundError: No module named 'mcp.server.fastmcp'`. SDK 2.0 removed
  `mcp.server.fastmcp` and renamed `FastMCP` to `MCPServer` under
  `mcp.server.mcpserver`; the import and construction now use the new name. The
  open-ended `mcp>=1.2.0` requirement meant a fresh `uvx altiplano` resolved
  SDK 2.x against code written for 1.x, so every launch broke.
