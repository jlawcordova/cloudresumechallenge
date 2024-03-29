import { defineConfig } from "cypress";

export default defineConfig({
  e2e: {
    setupNodeEvents(on, config) {
      // implement node event listeners here
    },
    baseUrl: "https://resume.jlawcordova.com/",
  },
  env: {
    API_URL: "https://api-resume.jlawcordova.com/",
  },
});
