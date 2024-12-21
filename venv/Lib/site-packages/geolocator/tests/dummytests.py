"""
 Unit tests. Add more!
"""

import unittest

from geolocator.providers import DummyProvider


__all__ = ("GeolocatorTestSuite",)

class DummyProviderCase(unittest.TestCase):
   "test the default"

   def setUp(self):
      self.provider = DummyProvider()
      self.country = "FI"
      self.city = "Helsinki"
      self.domain = "www.ficora.fi"
      self.ip = "194.100.96.83"

   def tearDown(self):
      del self.provider

   def testCityForIp(self):
      self.assertRaises(NotImplementedError, self.provider.getCityByIp, self.ip)

   def testCityForDomain(self):
      self.assertRaises(NotImplementedError, self.provider.getCityByDomain, self.domain)

   def testCountryForIp(self):
      self.assertRaises(NotImplementedError, self.provider.getCountryByIp, self.ip)

   def testCountryForDomain(self):
      self.assertRaises(NotImplementedError, self.provider.getCountryByDomain, self.domain)

   def testCoordinatesForIp(self):
      self.assertRaises(NotImplementedError, self.provider.getLocationByIp, self.ip)

   def testCoordinatesForDomain(self):
      self.assertRaises(NotImplementedError, self.provider.getLocationByDomain, self.domain)


DummyTestSuite = unittest.makeSuite(DummyProviderCase,'test')


if __name__ == "__main__":
   unittest.main()
   raw_input("press any key to quit...")
