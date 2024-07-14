from __future__ import annotations

from typing import Annotated, Sequence, TypedDict
import operator
from langchain_core.messages import BaseMessage, ToolMessage


class AgentState(TypedDict):
    messages: Annotated[Sequence[BaseMessage], operator.add]


class RawToolMessage(ToolMessage):
    """
    Customized Tool message that lets us pass around the raw tool outputs (along with string contents for passing back to the model).
    """

    raw: dict
    """Arbitrary (non-string) tool outputs. Won't be sent to model."""
    tool_name: str
    """Name of tool that generated output."""


__all__ = [
    "AgentState",
    "RawToolMessage"
]
