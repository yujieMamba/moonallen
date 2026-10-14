# Security and operational boundaries

MoonAllen is a local deterministic reasoning library. It performs no network,
filesystem, process, credential, or media access. Public parsers accept bounded
text, use a schema whitelist, and constrain identifiers. Source labels are data,
not executable expressions. DOT output excludes untrusted source labels.

This is not a safety-certified planner, a sandbox, a calendar engine, or a
hard-real-time system. Logical work budgets do not bound elapsed time or all
allocations. Do not apply the maximum budgets to unauthenticated concurrent
requests without external timeouts, process limits and admission control.
Possibility, entailment and core APIs may run multiple independent searches.

Unknown must remain distinct from Unsatisfiable. PathConsistent is not a SAT
certificate. Witness ranks are not timestamps, durations or executable schedules.
Reports and source labels can contain application data; sanitize before sharing.
JSON duplicate keys follow the standard core parser's last-key-wins behavior.
The Json-value decoder cannot undo memory allocation done by its caller.

For defects, use GitHub Issues with a minimal synthetic reproducer. Do not post
credentials, personal contact details, proprietary timelines or private datasets.
This project provides no private disclosure address or confidentiality promise.
