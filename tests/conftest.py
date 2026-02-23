"""pytest configuration for auto-news tests."""
import pytest
import os


@pytest.fixture
def sample_env_vars():
    """Sample environment variables fixture."""
    old_env = os.environ.copy()
    os.environ['AUTO_NEWS_CMD'] = 'airflow'
    os.environ['AUTO_NEWS_ARGS'] = 'webserver'
    yield os.environ.copy()
    os.environ.clear()
    os.environ.update(old_env)


@pytest.fixture
def sample_config_data():
    """Sample configuration data fixture."""
    return {
        'OPENAI_API_KEY': 'sk-test-key',
        'DATABASE_URL': 'postgresql://localhost:5432/auto_news',
        'REDIS_URL': 'redis://localhost:6379/0',
    }
