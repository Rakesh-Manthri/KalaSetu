from abc import ABC, abstractmethod
from typing import Any


class ModelBackend(ABC):
    @abstractmethod
    def load(self, model_path: str | None = None) -> None:
        """Load model weights/session into memory."""
        pass

    @abstractmethod
    def predict(self, input_data: Any) -> Any:
        """Run inference on the given input data."""
        pass
