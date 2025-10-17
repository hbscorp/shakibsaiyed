"""Unit tests for refactored app factory."""

import json
import unittest
from unittest.mock import Mock, patch

from service.app import create_app


class BaseTest(unittest.TestCase):
    def setUp(self):
        self.app = create_app()
        self.app.config["TESTING"] = True
        self.client = self.app.test_client()


class TestHealth(BaseTest):
    def test_health(self):
        res = self.client.get("/health")
        self.assertEqual(res.status_code, 200)
        body = json.loads(res.data)
        self.assertEqual(body["status"], "healthy")
        self.assertEqual(body["service"], "data-analytics-service")
        self.assertIn("timestamp", body)

    @patch("service.app._LazyStore")
    def test_storage_health_connected(self, lazy_cls):
        inst = Mock()
        inst.client.list_buckets.return_value = {"Buckets": []}
        lazy_cls.return_value = inst
        app = create_app()
        c = app.test_client()
        res = c.get("/storage/health")
        self.assertEqual(res.status_code, 200)
        body = json.loads(res.data)
        self.assertEqual(body["status"], "healthy")
        self.assertEqual(body["storage"], "connected")

    @patch("service.app._LazyStore")
    def test_storage_health_disconnected(self, lazy_cls):
        inst = Mock()
        inst.client.list_buckets.side_effect = Exception("boom")
        lazy_cls.return_value = inst
        app = create_app()
        c = app.test_client()
        res = c.get("/storage/health")
        self.assertEqual(res.status_code, 503)
        body = json.loads(res.data)
        self.assertEqual(body["status"], "unhealthy")
        self.assertEqual(body["storage"], "disconnected")


class TestRoot(BaseTest):
    def test_index(self):
        res = self.client.get("/")
        self.assertEqual(res.status_code, 200)
        body = json.loads(res.data)
        self.assertEqual(body["service"], "Data Analytics Hub - S3 Data Service")
        self.assertEqual(body["version"], "1.0.0")
        self.assertIn("endpoints", body)


if __name__ == "__main__":
    unittest.main()

