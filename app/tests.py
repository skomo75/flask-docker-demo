import main
import unittest

class FlaskrTestCase(unittest.TestCase):

    def setUp(self):
        self.app = main.app.test_client()

    def test_home_page(self):
        home_page = self.app.get('/')
        assert home_page.data.decode('utf-8') == 'Hello, World! This is version: 0.0.1'

if __name__ == '__main__':
    unittest.main()
