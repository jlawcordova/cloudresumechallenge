# The Cloud Resume Challenge

This project is a [monorepo](https://docs.npmjs.com/cli/v7/using-npm/workspaces) for [J. Law. Cordova's](https://github.com/jlawcordova) resume. This is the output for [The Cloud Resume Challenge (AWS Edition)](https://cloudresumechallenge.dev/docs/the-challenge/aws/) by [Forrest Brazeal](https://forrestbrazeal.com/).

The project is composed of a [React app](web), a [Lambda function in NodeJS](app), and a [Cypress test project](test). You can check each directory for their own corresponding guides.

From the [challenge website](https://cloudresumechallenge.dev/docs/faq/#what-is-the-cloud-resume-challenge),

> The Cloud Resume Challenge is a hands-on project designed to help you bridge the gap from cloud certification to cloud job. It incorporates many of the skills that real cloud and DevOps engineers use in their daily work.

# Getting Started

Install all dependencies by running:

`npm install`

Create a `.env` file in the `web` directory to setup the environment variables. In the `.env` file:

```
REACT_APP_API_BASE_URL=https://api-resume.jlawcordova.com/
```

Run commands for a workspace. For example, to run the React app:

`npm run start --workspace=web`

[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE) ![Deployment status](https://github.com/jlawcordova/cloudresumechallenge/actions/workflows/deploy-production.yml/badge.svg)
