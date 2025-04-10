import os
from django.http import HttpRequest, HttpResponse
from azure.core.credentials import AzureKeyCredential
from azure.ai.documentintelligence import DocumentIntelligenceClient
from azure.ai.documentintelligence.models import AnalyzeResult, DocumentAnalysisFeature
from azure.ai.documentintelligence.models import AnalyzeDocumentRequest
from django.views.decorators.csrf import csrf_exempt
import base64
import tempfile
import os
import base64
from django.contrib.auth import authenticate, login
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import json
from django.contrib.auth.models import User
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import json

endpoint = ""
key = ""
extracted_text = ""

def get_words(page, line):
    result = []
    for word in page.words:
        if _in_span(word, line.spans):
            result.append(word)
    return result

def _in_span(word, spans):
    for span in spans:
        if word.span.offset >= span.offset and (
                word.span.offset + word.span.length
        ) <= (span.offset + span.length):
            return True
    return False

def analyze_layout(file):
    document_intelligence_client = DocumentIntelligenceClient(
        endpoint=endpoint, credential=AzureKeyCredential(key)
    )

    file_content = base64.b64decode(file)
    with tempfile.NamedTemporaryFile(delete=False) as temp_file:
        temp_file.write(file_content)
        temp_file_path = temp_file.name

    # Decode the base64 string and save it to a temporary file
    path_to_sample_document = temp_file_path
    with open(path_to_sample_document, "rb") as f:
        poller = document_intelligence_client.begin_analyze_document(
            "prebuilt-read",
            analyze_request=f,
            features=[DocumentAnalysisFeature.LANGUAGES],
            content_type="application/octet-stream",
        )

    result: AnalyzeResult = poller.result()

    process_pages(result.pages)



def process_pages(pages):
    summary = ""

    if not pages or len(pages) == 0:
        summary += "No pages extracted from the document.\n"
    else:
        for page in pages:
            for line in page.get("lines", []):
                extracted_text += line.get("content", "") + "\n"

    return {"summary": summary, "extracted_text": extracted_text}


endpoint = os.getenv("ENDPOINT_URL", "")
deployment = os.getenv("DEPLOYMENT_NAME", "gpt-35-turbo")
subscription_key = os.getenv("AZURE_OPENAI_API_KEY", "REPLACE_WITH_YOUR_KEY_VALUE_HERE")

# Initialize Azure OpenAI Service client with key-based authentication
client = AzureOpenAI(
    azure_endpoint=endpoint,
    api_key=subscription_key,
    api_version="2024-05-01-preview",
)

# Prepare the chat prompt
chat_prompt = [
    {
        "role": "user",
        "content": extracted_text
    }
]

# Include speech result if speech is enabled
messages = chat_prompt

# Generate the completion
#completion = client.chat.completions.create(
#    model=deployment,
#    messages=messages,
#    max_tokens=800,
#    temperature=0.7,
#    top_p=0.95,
#    frequency_penalty=0,
#    presence_penalty=0,
#    stop=None,
#    stream=False
#)

#print(completion.to_json())


# Create your views here.
@csrf_exempt
def short_document(request: HttpRequest):
    if request.method == "POST":
        file = request.POST.get("file")
        analyze_layout(file)
        return HttpResponse("File processed successfully")

@csrf_exempt
def login_view(request: HttpRequest):
    if request.method == "GET":
        username = request.GET.get("username")
        password = request.GET.get("password")
        user = authenticate(request, username=username, password=password)
        if user is not None:
            login(request, user)
            return JsonResponse({"message": "Login successful"})
        else:
            return JsonResponse({"message": "Invalid credentials"}, status=401)
    return JsonResponse({"message": "Only POST method is allowed"}, status=405)


@csrf_exempt
def register_view(request: HttpRequest):
    if request.method == "GET":
        username = request.GET.get("username")
        password = request.GET.get("password")

        if not username or not password:
            return JsonResponse({"message": "Missing fields"}, status=400)

        if User.objects.filter(username=username).exists():
            return JsonResponse({"message": "Username already taken"}, status=400)

        user = User.objects.create_user(username=username, password=password)
        return JsonResponse({"message": "User registered successfully"})
    return JsonResponse({"message": "Only POST method is allowed"}, status=405)