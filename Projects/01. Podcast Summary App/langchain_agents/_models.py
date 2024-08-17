from typing import Literal
from langchain_groq import ChatGroq
from langchain_openai import ChatOpenAI


def get_llm(llm_type: Literal["llama3", "gpt"],
            llm_model: str,
            api_key: str,
            temperature: int = 0):
    if llm_type == "llama3":
        return ChatGroq(temperature=temperature, model=llm_model, groq_api_key=api_key)
    elif llm_type == "gpt":
        return ChatOpenAI(temperature=temperature, model=llm_model, openai_api_key=api_key)
    else:
        raise ValueError("Invalid LLM type")


__all__ = [
    "get_llm"
]
