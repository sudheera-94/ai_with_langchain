from __future__ import annotations

import io
import base64
import json
import contextlib
from PIL import Image
from IPython.display import display
from ._schemas import AgentState, RawToolMessage


def upload_dfs_to_python_env(state: AgentState) -> str:
    """
    Upload generated dfs to code interpreter and return code for loading them.
    TODO: Optimize this step
    """
    df_dicts = [
        msg.raw
        for msg in state["messages"]
        if isinstance(msg, RawToolMessage) and msg.tool_name in ("create_df_from_sql", "get_feedbacks")
    ]
    name_df_map = {name: df_path for df_dict in df_dicts for name, df_path in df_dict.items()}

    # Code for loading the uploaded files.
    df_code = "import pandas as pd\n" + "\n".join(
        f"{name} = pd.read_csv('{df_path}')" for name, df_path in name_df_map.items()
    )
    return df_code


def execute_script(script: str) -> dict:
    """
    Execute python script and return the result as a dictionary.
    """
    stdout = io.StringIO()
    stderr = io.StringIO()

    result = {
        'status': 'failed',
        'stdout': '',
        'stderr': ''
    }

    try:
        with contextlib.redirect_stdout(stdout), contextlib.redirect_stderr(stderr):
            exec(script)
        result['status'] = 'success'
    except Exception as e:
        result['stderr'] = str(e)

    result['stdout'] = stdout.getvalue()
    result['stderr'] = stderr.getvalue()

    return result


def convert_python_result_to_msg_content(python_result: dict) -> str:
    """
    Format python output from dictionary to string.
    """
    content = {}
    for k, v in python_result.items():
        # Any image results are returned as a dict of the form:
        # {"type": "image", "base64_data": "..."}
        if isinstance(python_result[k], dict) and python_result[k]["type"] == "image":
            # Decode and display image
            base64_str = python_result[k]["base64_data"]
            img = Image.open(io.BytesIO(base64.decodebytes(bytes(base64_str, "utf-8"))))
            display(img)
        else:
            content[k] = python_result[k]
    return json.dumps(content, indent=2)


__all__ = [
    "upload_dfs_to_python_env",
    "execute_script",
    "convert_python_result_to_msg_content"
]
