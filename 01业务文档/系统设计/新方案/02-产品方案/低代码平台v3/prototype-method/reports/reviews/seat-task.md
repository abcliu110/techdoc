# Council Seat Task

Read `prototype-method/reports/reviews/review-package.yaml` and only the files listed by it. Do not read existing review conclusions or peer outputs. Do not modify files.

Use the role named in the invocation. Treat `seat_interaction_observations` as raw coordinator observations, not guaranteed success. Evaluate only the role's domain. Output one JSON object with:

- `seat_id`
- `model_id`
- `interaction_reproduced`: true/false
- `findings`: array of `{id, severity, evidence, return_stage}`
- `vote`: `PASS` or `FAIL`
- `limitations`

Any open P0 or P1 requires `FAIL`. Missing required evidence cannot be converted to PASS. Do not claim competitor superiority.
