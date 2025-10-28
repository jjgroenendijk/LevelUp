---
created: 2025-10-28T11:13:44 (UTC +01:00)
tags: []
source: https://developers.openai.com/codex/cloud/code-review/
author: 
---

# Code Review

> ## Excerpt
> Use Codex to review code directly within GitHub.

---
Codex can review code directly in GitHub. This is great for finding bugs and improving code quality.

Before you can use Codex directly inside GitHub, you will need to make sure [Codex cloud](https://developers.openai.com/codex/cloud) is set up.

Afterwards, you can go into the [Codex settings](https://chatgpt.com/codex/settings/code-review) and enable “Code review” on your repository.

![](https://developers.openai.com/images/codex/code-review/code-review-settings.png)

After you have enabled Code review on your repository, you can start using it by tagging `@codex` in a comment on a pull request.

To trigger a review by codex you’ll have to specifically write `@codex review`.

![](https://developers.openai.com/images/codex/code-review/review-trigger.png)

Afterwards you’ll see Codex react to your comment with 👀 acknowledging that it started your task.

Once completed Codex will leave a regular code review in the PR the same way your team would do.

![](https://developers.openai.com/images/codex/code-review/review-example.png)

Codex automatically searches your repository for `AGENTS.md` files and follows any **Review guidelines** that you include in them. Add a top-level `AGENTS.md` file (or extend an existing one) with a section such as:

```
## Review guidelines
- Don't log PII.
- Verify that authentication middleware wraps every route.
```

Codex applies the guidance from the closest `AGENTS.md` file to each changed file, so you can place more specific instructions deeper in the tree when particular packages need extra scrutiny. For one-off requests, mention `@codex review for <special instruction>` in your PR comment (for example, `@codex review for security regressions`) and Codex will prioritize that focus area for that review.

If you mention `@codex` in a comment with anything other than `review` Codex will kick off a [cloud task](https://developers.openai.com/codex/cloud) instead with the context of your pull request.
