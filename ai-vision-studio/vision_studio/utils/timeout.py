"""Timeout execution utility for Vision Studio using concurrent.futures."""

from concurrent.futures import ThreadPoolExecutor, TimeoutError as FuturesTimeoutError
from typing import Any, Callable, TypeVar
from vision_studio.utils.errors import VisionStudioError, TIMEOUT

T = TypeVar("T")


def run_with_timeout(
    func: Callable[..., T],
    args: tuple[Any, ...] | list[Any] = (),
    seconds: float | None = None,
    kwargs: dict[str, Any] | None = None,
    timeout_seconds: float | None = None,
    stage: str = "pipeline",
) -> T:
    """Execute a callable with a hard timeout limit using concurrent.futures.

    Args:
        func: The callable target to execute.
        args: Positional arguments for the callable.
        seconds: Timeout limit in seconds (supports positional or keyword usage).
        kwargs: Keyword arguments for the callable.
        timeout_seconds: Alternative keyword argument for timeout limit in seconds.
        stage: Pipeline stage name associated with this execution for error context.

    Returns:
        The return value of func(*args, **(kwargs or {})).

    Raises:
        VisionStudioError: If execution exceeds timeout duration (code=TIMEOUT).
        Exception: Any exception raised by the target function.
    """
    effective_timeout = (
        seconds
        if seconds is not None
        else (timeout_seconds if timeout_seconds is not None else 20.0)
    )
    kw = kwargs if kwargs is not None else {}
    arg_tuple = tuple(args) if not isinstance(args, tuple) else args

    if effective_timeout <= 0:
        return func(*arg_tuple, **kw)

    with ThreadPoolExecutor(max_workers=1) as executor:
        future = executor.submit(func, *arg_tuple, **kw)
        try:
            return future.result(timeout=effective_timeout)
        except FuturesTimeoutError as exc:
            raise VisionStudioError(
                code=TIMEOUT,
                message=f"Execution timed out after {effective_timeout} seconds",
                stage=stage,
            ) from exc
