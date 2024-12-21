"""
 Unit tests. Add more!
"""

import unittest

from geolocator.providers import DummyProvider
from geolocator.providers import MaxMindCityDataProvider
from geolocator.providers import MaxMindCountryDataProvider

__all__ = ("MaxMindTestSuite",)

class MaxMindCountryProviderCase(unittest.TestCase):
   "test accessing the free country GeoIP data"

   def setUp(self):
      self.provider = MaxMindCountryDataProvider()
      self.country = "FI"
      self.city = "Helsinki"
      self.domain = "www.ficora.fi"
      self.ip = "194.100.96.83"
      self.location = (60.176, 24.934)


   def tearDown(self):
      del self.provider

   def testCountryByIp(self):
      ""
      self.assertEqual(self.provider.getCountryByIp(self.ip), self.country)

   def testCountryByDomain(self):
      ""
      self.assertEqual(self.provider.getCountryByDomain(self.domain),  self.country)



class MaxMindCityProviderCase(unittest.TestCase):
   "test accessing the commercial city GeoIP data"

   def setUp(self):
      self.provider = MaxMindCityDataProvider()
      self.country = "FI"
      self.city = "Helsinki"
      self.domain = "www.ficora.fi"
      self.ip = "194.100.96.83"
      self.location = ("60.176", "24.934")

   def tearDown(self):
      del self.provider

   def testCityForIp(self):
      self.assertEqual(self.provider.getCityByIp(self.ip), self.city)

   def testCityForDomain(self):
      self.assertEqual(self.provider.getCityByDomain(self.domain), self.city)

   def testCountryForIp(self):
      self.assertEqual(self.provider.getCountryByIp(self.ip), self.country)

   def testCountryForDomain(self):
      self.assertEqual(self.provider.getCountryByDomain(self.domain), self.country)

   def testLocationForIp(self):
      lat, lon = self.provider.getLocationByIp(self.ip)
      self.assertEqual( (str(round(lat,3)), str(round(lon,3))), self.location )

   def testLocationForDomain(self):
      lat, lon = self.provider.getLocationByDomain(self.domain)
      self.assertEqual( (str(round(lat,3)), str(round(lon,3))), self.location )

   #def testLocationForCity(self):
   #   self.assertEqual(self.provider.getLocationByIp(self.city), self.location)


MaxMindCountryTestSuite = unittest.makeSuite(MaxMindCountryProviderCase,'test')
MaxMindCityTestSuite = unittest.makeSuite(MaxMindCityProviderCase,'test')
MaxMindTestSuite = unittest.TestSuite((MaxMindCountryTestSuite, MaxMindCityTestSuite))

if __name__ == "__main__":
   unittest.main()
   raw_input("press any key to quit...")
