from __future__ import annotations

from langchain_core.pydantic_v1 import BaseModel, Field
from typing import List
from langchain_core.tools import tool


@tool
class create_df_from_sql(BaseModel):
    """Execute a PostgreSQL SELECT statement and use the results to create a DataFrame with the given column names."""

    select_query: str = Field(..., description="A PostgreSQL SELECT statement.")
    # We're going to convert the results to a Pandas DataFrame that we pass
    # to the code interpreter, so we also have the model generate useful column and
    # variable names for this DataFrame that the model will refer to when writing
    # python code.
    df_columns: List[str] = Field(
        ..., description="Ordered names to give the DataFrame columns."
    )
    df_name: str = Field(
        ..., description="The name to give the DataFrame variable in downstream code."
    )
    input_question: str = Field(
        ...,
        description="The question that given to the model to generate the SQL query.",
    )


# Tool schema for writing Python code
@tool
class python_shell(BaseModel):
    """Execute Python code that analyzes the DataFrames that have been generated.
    Make sure to print any important results."""

    code: str = Field(
        ...,
        description="The code to execute. Make sure to print any important results.",
    )


__all__ = [
    "create_df_from_sql",
    "python_shell"
]
