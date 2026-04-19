---
name: code-commit
description: Understands the changes done in the current session and then writes a concise commit message 5-7 words sentence when committing the changes
---

# code-commit

You are about to commit the changes made in the current session. Follow these steps precisely:

## Steps

1. **Review changes** — Run `git status` and `git diff` to understand what was modified, added, or deleted.

2. **Summarize the intent** — Based on the diff and the conversation context, determine the *why* behind the changes (new feature, bug fix, refactor, config update, etc.).

3. **Write the commit message** — Follow these rules:
   - Subject line: 5–7 words, imperative mood, no period at the end
   - Use a conventional prefix: `feat:`, `fix:`, `refactor:`, `chore:`, `docs:`, `style:`, `test:`
   - If multiple concerns are touched, pick the dominant one
   - No bullet lists in the subject line — save detail for the body if truly needed

4. **Stage the right files** — Add specific files by name. Never use `git add -A` or `git add .` unless every untracked file is intentional. Skip `.env`, secrets, or large binaries.

5. **Commit** — Use a HEREDOC to pass the message cleanly:
   ```bash
   git commit -m "$(cat <<'EOF'
   feat: add mood streak calculation to provider

   Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
   EOF
   )"
   ```

6. **Confirm** — Run `git status` after the commit to verify it succeeded.

## Rules

- NEVER amend an existing commit unless the user explicitly asks
- NEVER skip hooks (`--no-verify`)
- NEVER commit if there is nothing staged
- NEVER push unless the user explicitly asks
- If a pre-commit hook fails, fix the issue and create a **new** commit — do not amend
- Always include the `Co-Authored-By` trailer

## Commit Message Examples

| Change | Message |
|--------|---------|
| New mood trend screen | `feat: add mood trends screen` |
| Fix moodTags enum mismatch | `fix: align moodTags enum with mood types` |
| Center all screen layouts | `style: center layout with ConstrainedBox pattern` |
| Seed script for DB | `chore: add DB seed script for affirmations` |
| Remove unused import | `refactor: remove unused auth import` |
