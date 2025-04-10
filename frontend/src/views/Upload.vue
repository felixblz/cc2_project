<script setup>
import {ref} from "vue";
import Spinner from "@/views/Spinner.vue";

function* getTextOfSpans(content, spans) {
  for (const span of spans) {
    yield content.slice(span.offset, span.offset + span.length);
  }
}
const file = ref(null);
const answer = ref("");
const loading = ref(false);

function onFileChange(event) {
  const selectedFile = event.target.files[0];
  if (!selectedFile) {
    console.error("No file selected.");
    return;
  }
  file.value = selectedFile;
}

function uploadFile() {
  console.log("Uploading file:", file.value.name);
  if (!file.value) {
    console.error("No file selected.");
    return;
  }

  const reader = new FileReader();
  reader.onload = async () => {
    const base64File = reader.result.split(",")[1];
    console.log("Base64 file:", base64File);
    await askAPI(base64File);
  };
  reader.onerror = (error) => {
    console.error("Error reading file:", error);
  };
  reader.readAsDataURL(file.value);
}


async function askAPI(base64) {
  const response = fetch('/api/doc', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      file: base64
    })
  })
  if(response.ok) {
    answer.value = response.body;
  }
}

</script>

<template>
  <div class="container">
    <h1>Upload and analyze document</h1>
    <label for="file-upload">Choose File</label>
    <input id="file-upload" accept=".pdf" type="file" @change="onFileChange"/>
    <button @click="uploadFile" style="margin-left: 100px">Upload</button>
    <p>{{ answer }}</p>
    <Spinner v-if="loading"/>
  </div>
</template>

<style scoped>
body {
  font-family: Arial, sans-serif;
  background-color: #f4f4f9;
  margin: 0;
  padding: 0;
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100vh;
}

.container {
  background-color: #fff;
  padding: 20px;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  text-align: center;
  max-width: 400px;
  width: 100%;
}

h1 {
  font-size: 24px;
  margin-bottom: 20px;
  color: #333;
}

input[type="file"] {
  display: none;
}

label {
  display: inline-block;
  padding: 10px 20px;
  background-color: #007bff;
  color: #fff;
  border-radius: 4px;
  cursor: pointer;
  margin-bottom: 20px;
}

button {
  padding: 10px 20px;
  background-color: #28a745;
  color: #fff;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  margin-top: 10px; /* Add margin-top to create space between buttons */
}

button:hover {
  background-color: #218838;
}

p {
  margin-top: 20px;
  color: #555;
}
</style>