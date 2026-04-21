import os
import tempfile
import json
from fastapi import FastAPI, UploadFile, File, Form, HTTPException
from fastapi.responses import JSONResponse
from aeneas.executetask import ExecuteTask
from aeneas.task import Task

app = FastAPI(title="Aeneas Forced Alignment API")

@app.post("/align")
async def align(
    audio: UploadFile = File(...),
    text: UploadFile = File(...),
    language: str = Form("ru")
):
    try:
        # Create temporary files for processing
        with tempfile.NamedTemporaryFile(delete=False, suffix=".mp3") as temp_audio:
            temp_audio.write(await audio.read())
            audio_path = temp_audio.name
            
        with tempfile.NamedTemporaryFile(delete=False, suffix=".txt") as temp_text:
            temp_text.write(await text.read())
            text_path = temp_text.name
            
        output_path = audio_path + ".json"

        # Configure the Aeneas Task
        task = Task()
        task.configuration_string = f"task_language={language}|os_task_file_format=json|is_text_type=plain"
        task.audio_file_path_absolute = audio_path
        task.text_file_path_absolute = text_path
        task.sync_map_file_path_absolute = output_path

        # Execute alignment deterministically
        ExecuteTask(task).execute()
        task.output_sync_map_file()

        # Read and return the resulting JSON
        with open(output_path, "r", encoding="utf-8") as f:
            result = json.load(f)

        # Clean up temporary files
        os.remove(audio_path)
        os.remove(text_path)
        os.remove(output_path)

        return JSONResponse(content=result)

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
