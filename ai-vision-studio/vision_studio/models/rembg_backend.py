from typing import Any
from .base import ModelBackend


class RembgBackend(ModelBackend):
    def __init__(self, model_name: str = "u2net"):
        self.model_name = model_name

    def load(self, model_path: str | None = None) -> None:
        raise NotImplementedError("RembgBackend.load is not implemented in Phase 1 stub.")

    def predict(self, input_data: Any) -> Any:
        raise NotImplementedError("RembgBackend.predict is not implemented in Phase 1 stub.")
