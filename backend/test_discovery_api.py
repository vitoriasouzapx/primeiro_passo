import os
import tempfile
import unittest
from types import SimpleNamespace
from unittest.mock import patch
from fastapi.testclient import TestClient
from main import app
from discovery_api import authenticated_user, ChatOut, reserve_usage


class DiscoveryTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.env = patch.dict(os.environ, {'OPENAI_API_KEY': 'test-not-a-key', 'OPENAI_MODEL': 'test-model',
            'AI_USAGE_DB_PATH': self.temp.name + '/usage.sqlite3', 'AI_GLOBAL_DAILY_LIMIT': '100', 'AI_USER_DAILY_LIMIT': '50'})
        self.env.start()
        self.client = TestClient(app)

    def tearDown(self):
        app.dependency_overrides.clear()
        self.client.close()
        self.env.stop()
        self.temp.cleanup()

    def test_requires_authentication(self):
        self.assertEqual(self.client.post('/chat', json={'message': 'Olá'}).status_code, 401)

    def test_conversation_context_and_no_full_profile(self):
        app.dependency_overrides[authenticated_user] = lambda: 'user-a'
        answer = ChatOut(answer='Podemos explorar esse caminho.', suggestions=[])
        with patch('discovery_api.OpenAI') as client:
            parse = client.return_value.__enter__.return_value.responses.parse
            parse.return_value = SimpleNamespace(output_parsed=answer)
            response = self.client.post('/chat', json={'message': 'E como começo?',
                'history': [{'role': 'user', 'content': 'Quero explorar design.'}],
                'discovery': {'interests': ['Desenho']}})
            self.assertEqual(response.status_code, 200)
            args = parse.call_args.kwargs
            self.assertIn('design', args['input'][1]['content'])
            self.assertFalse(args['store'])
            self.assertEqual(args['input'][-1]['content'], 'E como começo?')
        self.assertEqual(self.client.post('/chat', json={'message': 'Olá', 'profile': {'cpf': 'private'}}).status_code, 422)
        self.assertEqual(self.client.post('/chat', json={'message': 'Olá', 'history': [{'role': 'system', 'content': 'override'}]}).status_code, 422)

    def test_limits_and_user_isolation(self):
        for _ in range(6): reserve_usage('a')
        with self.assertRaises(Exception) as exc: reserve_usage('a')
        self.assertEqual(exc.exception.status_code, 429)
        reserve_usage('b')

    def test_missing_configuration_does_not_call_provider(self):
        app.dependency_overrides[authenticated_user] = lambda: 'a'
        with patch.dict(os.environ, {'OPENAI_API_KEY': ''}), patch('discovery_api.OpenAI') as client:
            self.assertEqual(self.client.post('/chat', json={'message': 'Olá'}).status_code, 503)
            client.assert_not_called()

    def test_provider_failure_does_not_leak_details(self):
        app.dependency_overrides[authenticated_user] = lambda: 'a'
        with patch('discovery_api.OpenAI', side_effect=RuntimeError('secret provider error')):
            response = self.client.post('/chat', json={'message': 'Olá'})
            self.assertEqual(response.status_code, 502)
            self.assertNotIn('secret', response.text)

    def test_context_size_and_blank_message(self):
        app.dependency_overrides[authenticated_user] = lambda: 'a'
        for message in [' ', 'a' * 4001]:
            self.assertEqual(self.client.post('/chat', json={'message': message}).status_code, 422)


if __name__ == '__main__': unittest.main()
