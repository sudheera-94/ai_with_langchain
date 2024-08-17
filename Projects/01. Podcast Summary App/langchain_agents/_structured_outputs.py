from __future__ import annotations

from langchain_core.pydantic_v1 import BaseModel, Field


# Data model for the decide_is_semantic output
class IsSemantic(BaseModel):
    """Binary score for related check on customer feedbacks analysis"""

    binary_score: int = Field(
        description="Is the question related to customer feedbacks, 1 if yes, 0 if no"
    )


# Data model for the generate_python_script output
class PythonScript(BaseModel):
    """Python code to analyze the DataFrames that have been generated."""

    code: str = Field(
        ...,
        description="The code to execute. Make sure to print any important results. "
                    "Print a short comment about the result as well.",
    )


class FeedbackAnalysis(BaseModel):
    """Information from Feedback"""

    rating: int = Field(
        description="The sentiment score which is calculated using the customer feedback. "
                    "It has to be on a scale of 1 to 10, where 1 represents extremely negative sentiment and "
                    "10 represents extremely positive sentiment"
    )
    summary: str = Field(
        default=None,
        description=(
            "A very short summary of the feedback with keywords and phrases which have affected the sentiment score."
            "This has to be less than 30 words. Make it as short as possible.")
    )


__all__ = [
    "IsSemantic",
    "PythonScript",
    "FeedbackAnalysis"
]
