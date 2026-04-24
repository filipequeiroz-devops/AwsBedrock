# AWS Cloud Authentication & Secure Serverless Architecture

**Language / Idioma**: [🇺🇸 English](#-project-overview) | [🇧🇷 Português](#-visão-geral-do-projeto)

<div align="center">

![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54)
![Pytest](https://img.shields.io/badge/pytest-%230A9EDC.svg?style=for-the-badge&logo=pytest&logoColor=white)
![JavaScript](https://img.shields.io/badge/javascript-%23323330.svg?style=for-the-badge&logo=javascript&logoColor=%23F7DF1E)
![Amazon API Gateway](https://img.shields.io/badge/Amazon%20API%20Gateway-FF4F8B?style=for-the-badge&logo=amazonapigateway&logoColor=white)
![AWS Lambda](https://img.shields.io/badge/AWS%20Lambda-FF9900?style=for-the-badge&logo=awslambda&logoColor=white)
![Amazon Cognito](https://img.shields.io/badge/Amazon%20Cognito-DD344C?style=for-the-badge&logo=amazoncognito&logoColor=white)
![Amazon S3](https://img.shields.io/badge/Amazon%20S3-569A31?style=for-the-badge&logo=amazons3&logoColor=white) 

</div>

---

## 🇺🇸 Project Overview

This project implements a secure **Serverless Authentication Architecture** designed for high scalability and cost-efficiency. It focuses on identity management using **AWS Cognito** and infrastructure protection through **API Gateway Authorizers** and **Terraform**.

### 🏗️ Architecture & Security Workflow

1.  **Identity Management:** Utilizes **AWS Cognito User Pools** for secure user registration and email verification.
2.  **API Security:** Implemented a **JWT (JSON Web Token) Authorizer** at the **API Gateway** level.
3.  **State Management:** Secure handling of tokens using **LocalStorage** and **Route Guards**.
4.  **Infrastructure as Code (IaC):** 100% of the environment is managed via **Terraform**.
5.  **Quality Assurance:** Backend logic is validated through automated **Unit Tests** using **Pytest**, ensuring Lambda functions handle payloads and exceptions correctly.

> **Live Demo:** [Check it working here](http://randombucket-2026-filipe.s3-website-us-east-1.amazonaws.com)

---

## 🇧🇷 Visão Geral do Projeto

Este projeto implementa uma **Arquitetura de Autenticação Serverless** segura, projetada para alta escalabilidade e baixo custo. O foco principal é a gestão de identidade usando **AWS Cognito** e a proteção de infraestrutura através de **Authorizers no API Gateway** e **Terraform**.

### 🏗️ Arquitetura e Fluxo de Segurança

1.  **Gestão de Identidade:** Utiliza **AWS Cognito User Pools** para registro seguro e verificação de e-mail.
2.  **Segurança de API:** Implementação de um **Authorizer JWT** no **API Gateway**.
3.  **Gestão de Estado:** Manipulação de tokens via **LocalStorage** e **Route Guards** em JavaScript.
4.  **Infraestrutura como Código (IaC):** Todo o ambiente é provisionado via **Terraform**.
5.  **Garantia de Qualidade:** A lógica do backend é validada através de **Testes Unitários** automatizados com **Pytest**, garantindo que as Lambdas processem payloads e exceções corretamente.

---

### 🚀 Tech Stack & Testing

* **Cloud:** AWS (Cognito, API Gateway, Lambda, S3).
* **IaC:** Terraform.
* **Testing:** **Pytest** for backend validation.
* **CI/CD:** GitHub Actions for automated deployment and test execution.

---

<div align="center">
  <sub>Developed by **Filipe Queiroz** as part of a DevOps & SRE Career Transition Portfolio.</sub>
</div>