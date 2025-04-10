<script setup>
    import { ref } from 'vue';
    import router from "@/router/index.js";

    const username = ref('');
    const password = ref('');

    async function login() {
      console.log('Logging in with', username.value, password.value);
      const response = await fetch(`/api/login?username=${username.value}&password=${password.value}`)
      if (response.ok) {
        const data = await response.json();
        console.log('Login successful:', data);
        await router.push('/upload');
        // Handle successful login (e.g., redirect to dashboard)
      } else {
        const error = await response.json();
        console.error('Login failed:', error);
        alert("Login failed!")
        // Handle login failure (e.g., show error message)
      }
    }

    async function register() {
      console.log('Registering with', username.value, password.value);
      const response = await fetch(`/api/register?username=${username.value}&password=${password.value}`)
      if (response.ok) {
        const data = await response.json();
        console.log('Registration successful:', data);
        alert("Registration successful!")
      } else {
        const error = await response.json();
        console.error('Registration failed:', error);
        alert("Registration failed!")
      }
    }
    </script>

    <template>
      <div class="login-container">
        <h1>Login</h1>
        <form @submit.prevent="login">
          <div class="form-group">
            <label for="username">Username</label>
            <input type="text" id="username" v-model="username" required />
          </div>
          <div class="form-group">
            <label for="password">Password</label>
            <input type="password" id="password" v-model="password" required />
          </div>
          <div class="button-group">
            <button type="submit">Login</button>
            <button type="button" @click="register">Register</button>
          </div>
        </form>
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

    .login-container {
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

    .form-group {
      margin-bottom: 15px;
      text-align: left;
    }

    label {
      display: block;
      margin-bottom: 5px;
      color: #333;
    }

    input {
      width: 100%;
      padding: 10px;
      border: 1px solid #ccc;
      border-radius: 4px;
    }

    .button-group {
      display: flex;
      justify-content: space-between;
    }

    button {
      padding: 10px 20px;
      background-color: #007bff;
      color: #fff;
      border: none;
      border-radius: 4px;
      cursor: pointer;
      width: 48%;
    }

    button:hover {
      background-color: #0056b3;
    }
    </style>