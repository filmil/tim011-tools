## Python dependencies

Update python dependencies by running:

```bash
bazel run //third_party:requirements.update
```

You will need to run this every time the Python requirements are modified at
[`//third_party:requirements.in`](req).

[req]: ../third_party/requirements.in
