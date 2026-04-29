MrTFT App — Teamfight Tactics Analytics iOS Application

A full-stack iOS application that ingests and analyzes Teamfight Tactics (TFT) match data using a production-deployed backend on AWS. The system processes external API data into a structured relational schema and serves real-time analytics to a mobile client.

Overview

MrTFT is designed to mirror real-world production systems by combining a mobile frontend with a scalable backend and managed cloud infrastructure. The backend handles data ingestion, transformation, storage, and API serving, while the iOS client consumes the deployed API for real-time analytics.

System Architecture
iOS Client (Swift)
    ↓
Application Load Balancer (AWS)
    ↓
ECS Fargate (FastAPI backend, Dockerized)
    ↓
Amazon RDS (PostgreSQL)

Core Functionality
Ingests match data from the Riot Games API
Transforms nested JSON responses into normalized relational tables
Computes player-level statistics including average placement, win rate, and match history
Serves analytics through RESTful API endpoints
Enables real-time data refresh through mobile client integration

Backend Design
Data Pipeline
Pulls match data from external Riot API
Performs transformation of deeply nested JSON into structured relational format
Stores data in PostgreSQL with normalized schema to reduce redundancy and support efficient queries

Database Schema
Matches
Participants
Traits
Unit compositions

Designed to support:
Join-heavy analytical queries
Aggregations for player statistics
Scalable ingestion of match data

API Endpoints
/ingest/{player}/{region}
/players/{player}/summary
/players/{player}/recent
/players/{player}/placement-distribution
Deployment

The backend is deployed as a containerized service on AWS:

Dockerized FastAPI application
Images stored in Amazon ECR
Deployed via ECS Fargate (serverless containers)
Application Load Balancer routes external traffic
Amazon RDS PostgreSQL used for persistent storage

Tech Stack
Mobile
Swift
SwiftUI
URLSession

Backend
Python
FastAPI
SQLAlchemy
Uvicorn

Infrastructure
Docker
AWS ECS Fargate
AWS ECR
AWS Application Load Balancer
AWS RDS (PostgreSQL)

Local Development
Backend
cd backend
docker-compose up --build

iOS
Open the project in Xcode and run on a simulator or device.

Environment Configuration
DATABASE_URL=postgresql://user:password@host:5432/db
RIOT_API_KEY=your_api_key
RIOT_REGION=...
RIOT_PLATFORM=...

Engineering Highlights
Designed and implemented a data ingestion pipeline converting external API data into a normalized relational schema
Built RESTful APIs to support real-time analytics queries with efficient database access patterns
Deployed a containerized backend using AWS ECS Fargate with managed load balancing and database services
Integrated mobile client with production API, enabling end-to-end system functionality
Debugged and resolved distributed system issues including container deployment failures, networking configuration, and database connectivity

Future Work
Add HTTPS with custom domain and SSL via AWS Certificate Manager
Implement CI/CD pipeline for automated build and deployment
Introduce database migrations using Alembic
Add caching layer for performance optimization

Author
Jeff Jimenez
GitHub: https://github.com/jefferinooo