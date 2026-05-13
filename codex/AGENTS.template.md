<!-- sonbbal-superpowers-codex:start -->
## Sonbbal Superpowers for Codex

This project uses the `sonbbal-superpowers-codex` plugin package.

- At the start of each task, check the installed Codex skills and follow `using-superpowers` when any Sonbbal workflow may apply.
- Prefer Codex-native skills from this package. Do not use Claude Code commands, hooks, or agents for Codex work.
- For implementation work, use the relevant skills such as `brainstorming`, `writing-plans`, `executing-plans`, `test-driven-development`, and `verification-before-completion`.
- Use `team-driven-development` only when the user explicitly asks for subagents, delegation, parallel agent work, reviewer workflow, or a team workflow.
- Treat worker self-reports as insufficient completion evidence. Inspect the actual diff and verification output before claiming completion.
- If the plugin runtime is unavailable, the project fallback skill link is `.agents/skills/sonbbal-superpowers-codex`.
<!-- sonbbal-superpowers-codex:end -->
