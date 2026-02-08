#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
tutorial_poc.py - Auto-News Tutorial Proof of Concept

This script demonstrates how to use Auto-News through Docker for automatic
news aggregation and processing tasks.
"""

import os
import sys


def print_section(title):
    """Print a formatted section header."""
    print("\n" + "=" * 70)
    print(f"  {title}")
    print("=" * 70 + "\n")


def demo_features():
    """Show supported features."""
    print_section("Auto-News Features")

    features = '''
Auto-News provides the following capabilities:

1. CONTENT AGGREGATION
   - RSS feed monitoring
   - Reddit post fetching
   - Twitter/X tweet collection
   - YouTube video processing

2. CONTENT PROCESSING
   - Article summarization
   - Insight generation using LLM
   - Content filtering based on interests
   - Duplicate detection

3. MULTIMODAL SUPPORT
   - Video transcript extraction
   - Video recap generation
   - Web article parsing
   - PDF processing

4. REPORTING
   - Weekly top-k recap
   - Daily insights summary
   - Unified reading experience
   - Notion-based integration

5. TASK AUTOMATION
   - Scheduled content collection
   - Automated insight generation
   - TODO list creation
   - Journal note organization
'''
    print(features)


def demo_docker_usage():
    """Demo Docker usage."""
    print_section("Docker Usage Examples")

    docker_commands = '''
# Build the Docker image
cd auto-news
docker build -t auto-news:latest .

# Start with docker-compose
docker-compose up -d

# Or start manually
docker run -d \\
    --name auto-news \\
    -p 11190:8080 \\
    -v $(pwd)/workspace:/opt/airflow/workspace:rw \\
    -v $(pwd)/logs:/opt/airflow/logs:rw \\
    -v $(pwd)/dags:/opt/airflow/dags:ro \\
    -v $(pwd)/.env:/opt/airflow/.env:ro \\
    --env-file .env \\
    auto-news:latest

# View logs
docker logs -f auto-news

# Access the Airflow webserver
open http://localhost:11190

# Stop the container
docker-compose down
or
docker stop auto-news
'''
    print(docker_commands)


def demo_configuration():
    """Show configuration options."""
    print_section("Configuration Options")

    config_info = '''
Required Environment Variables (.env file):

# LLM Configuration
OPENAI_API_KEY=your-api-key-here
OPENAI_BASE_URL=https://api.openai.com/v1

# Alternative LLM providers
ANTHROPIC_API_KEY=your-anthropic-key
GOOGLE_API_KEY=your-google-key

# Data Stores
MYSQL_HOST=localhost
MYSQL_USER=root
MYSQL_PASSWORD=your-password

# Vector Database (optional)
PINECONE_API_KEY=your-pinecone-key
CHROMA_PORT=8000

# RSS Sources
RSS_FEEDS=https://example.com/rss

# Notion Integration
NOTION_TOKEN=your-notion-token
'''
    print(config_info)


def demo_workflow():
    """Show the processing workflow."""
    print_section("Content Processing Workflow")

    workflow = '''
1. CONTENT COLLECTION
   ├── RSS feeds monitored
   ├── Reddit posts fetched
   ├── Twitter/X tweets collected
   └── YouTube videos processed

2. CONTENT ANALYSIS
   ├── Extract article content
   ├── Generate embeddings
   ├── Store in vector database
   └── Extract key insights

3. AI PROCESSING
   ├── Summarize content
   ├── Generate insights
   ├── Filter by interests
   └── Create TODO items

4. OUTPUT
   ├── Notion integration
   ├── Weekly recap
   ├── Daily digest
   └── Personalized feed
'''
    print(workflow)


def demo_python_api():
    """Demo Python API usage."""
    print_section("Python API Examples")

    api_code = '''
import sys
import os
sys.path.insert(0, os.path.dirname(__file__))

# Example: Using Auto-News programmatically

from auto_news.sources.rss import RSSFeed
from auto_news.sources.youtube import YouTubeProcessor
from auto_news.processors.summarizer import ContentSummarizer

# Monitor RSS feed
rss = RSSFeed(url="https://example.com/feed")
articles = rss.fetch_articles()

# Process YouTube video
yt = YouTubeProcessor(video_id="xyz")
transcript = yt.get_transcript()
summary = yt.generate_recap()

# Summarize content
summarizer = ContentSummarizer()
result = summarizer.summarize(articles[0])
'''
    print(api_code)


def demo_supported_sources():
    """Show supported data sources."""
    print_section("Supported Data Sources")

    sources = '''
RSS Feeds:
- Any standard RSS feed
- Atom feeds
- Multiple feed monitoring

Social Media:
- Reddit (subreddits)
- Twitter/X posts
- User timelines

Video Platforms:
- YouTube videos
- Transcript extraction
- Video recap generation

Web Content:
- Article parsing
- PDF processing
- Web scraping

Knowledge Bases:
- Notion integration
- Vector databases
- Custom data sources
'''
    print(sources)


def demo_storage():
    """Show storage requirements."""
    print_section("Storage and Requirements")

    storage = '''
Disk Space:
- Airflow metadata: 1GB
- Content cache: 5GB+
- Vector database: 10GB+
- Logs: 1GB+

Total Recommended: 20GB+

RAM:
- Minimum: 8GB
- Recommended: 16GB+

CPU:
- Minimum: 2 cores
- Recommended: 4+ cores
'''
    print(storage)


def demo_quick_start():
    """Quick start guide."""
    print_section("Quick Start Guide")

    quick_start = '''
1. PREREQUISITES
   Docker installed
   OpenAI API key (or alternative LLM)
   MySQL database (or use SQLite for dev)

2. SETUP
   git clone https://github.com/finaldie/auto-news.git
   cd auto-news
   cp .env.template .env
   # Edit .env with your API keys

3. BUILD AND RUN
   docker build -t auto-news:latest .
   docker-compose up -d

4. FIRST USE
   Access http://localhost:11190
   Configure RSS feeds in Airflow
   Run DAGs to collect content
   View results in Notion

5. MONITORING
   docker logs -f auto-news
   Check Airflow web UI for DAG status
'''
    print(quick_start)


def main():
    """Main entry point."""
    print("\n" + "/Auto-News Tutorial POC".center(70, "="))
    print("  Automatic News Aggregator with LLM".center(70))
    print("=" * 70)

    # Run demos
    demo_features()
    demo_docker_usage()
    demo_configuration()
    demo_workflow()
    demo_python_api()
    demo_supported_sources()
    demo_storage()
    demo_quick_start()

    # Summary
    print_section("Quick Start Summary")

    summary = '''
1. SETUP
   - Install Docker
   - Get API keys (OpenAI/Anthropic/etc.)
   - Clone the repository

2. CONFIGURE
   - Copy .env.template to .env
   - Add your API keys
   - Configure RSS feeds

3. DEPLOY
   - Build: docker build -t auto-news:latest .
   - Run: docker-compose up -d

4. USE
   - Access Airflow web UI
   - Monitor content collection
   - View processed content

For more information, visit: https://github.com/finaldie/auto-news
'''
    print(summary)

    return 0


if __name__ == "__main__":
    sys.exit(main())
