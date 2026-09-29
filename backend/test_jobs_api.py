import os
import tempfile
import unittest
from fastapi.testclient import TestClient
from main import app


class JobsTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        os.environ['JOBS_DB_PATH'] = os.path.join(self.temp.name, 'jobs.sqlite3')
        os.environ['JOBS_ADMIN_TOKEN'] = 'test-only-token'
        self.client = TestClient(app)
        self.headers = {'X-Admin-Token': 'test-only-token'}
        self.job = {'title': 'Assistente', 'company': 'Empresa Exemplo',
                    'requirements': {'Excel': 0.7}, 'application_url': 'https://example.com/vagas/1'}

    def tearDown(self):
        self.client.close()
        self.temp.cleanup()

    def test_empty_feed_and_pagination(self):
        self.assertEqual(self.client.get('/jobs').json(), {'items': [], 'has_more': False})
        for key in ['a', 'b']:
            self.assertEqual(self.client.put('/admin/jobs/' + key, json=self.job, headers=self.headers).status_code, 200)
        page1 = self.client.get('/jobs?page_size=1').json()
        page2 = self.client.get('/jobs?page_size=1&page=2').json()
        self.assertTrue(page1['has_more'])
        self.assertFalse(page2['has_more'])
        self.assertNotEqual(page1['items'][0]['id'], page2['items'][0]['id'])

    def test_protected_write_and_invalid_input(self):
        self.assertEqual(self.client.put('/admin/jobs/a', json=self.job).status_code, 401)
        bad = dict(self.job, requirements={'Excel': 2})
        self.assertEqual(self.client.put('/admin/jobs/a', json=bad, headers=self.headers).status_code, 422)
        bad = dict(self.job, application_url='javascript:alert(1)')
        self.assertEqual(self.client.put('/admin/jobs/a', json=bad, headers=self.headers).status_code, 422)
        os.environ.pop('JOBS_ADMIN_TOKEN')
        self.assertEqual(self.client.put('/admin/jobs/a', json=self.job, headers=self.headers).status_code, 503)

    def test_update_and_deactivate(self):
        self.client.put('/admin/jobs/a', json=self.job, headers=self.headers)
        self.client.put('/admin/jobs/a', json=dict(self.job, company='Nova Empresa'), headers=self.headers)
        self.assertEqual(self.client.get('/jobs').json()['items'][0]['company'], 'Nova Empresa')
        self.assertEqual(self.client.delete('/admin/jobs/a', headers=self.headers).status_code, 200)
        self.assertEqual(self.client.get('/jobs').json()['items'], [])
        self.assertEqual(self.client.delete('/admin/jobs/missing', headers=self.headers).status_code, 404)

    def test_jobs_without_ai_key_and_cors(self):
        os.environ.pop('OPENAI_API_KEY', None)
        self.assertEqual(self.client.get('/health').status_code, 200)
        result = self.client.get('/jobs', headers={'Origin': 'http://localhost:5300'})
        self.assertEqual(result.headers['access-control-allow-origin'], 'http://localhost:5300')
        self.assertEqual(self.client.post('/chat', json={'message': 'oi'}).status_code, 401)


if __name__ == '__main__':
    unittest.main()
