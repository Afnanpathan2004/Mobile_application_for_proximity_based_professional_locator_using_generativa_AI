"""
  Data provider implementations

   - MaxMind providers are initialized with the path to the binary database.

"""

import os

__all__ = ["CountryProvider","CityProvider"]

LOCATIONS   = ("./data", "/usr/share/GeoIP", "/usr/local/share/GeoIP")
COUNTRYDATA_FILENAME = "GeoIP.dat"
CITYDATA_FILENAME    = "GeoIPCity.dat"

class BaseProvider:
   "base class"

   def __init__(self, filepath=None, init_type="GEOIP_MEMORY_CACHE"):
      try:
         import GeoIP
      except Exception, e:
         hlp = "(note that you need both the C library & the Python extension)"
         raise Exception("GeoIP python extension could not be imported: %s\n%s" % (e,hlp))

      if filepath==None:
         for location in LOCATIONS:
            try:
               filepath = location +  os.sep + self.filename
               file = open(filepath)
               file.close()
               break
            except:
               pass

      # could also use GEOIP_STANDARD
      try:
         import GeoIP
         self.database = GeoIP.open(filepath, getattr(GeoIP,init_type))
      except Exception, e:
         raise Exception("could not open MaxMind data: %s" %e)


class CountryProvider(BaseProvider):
   """
   Provider for the free MaxMind country IP data
   """

   filename = COUNTRYDATA_FILENAME

   def getCountryByIp(self,ip):
      "return the country code"
      return self.database.country_code_by_addr(ip)


   def getCountryByDomain(self, domain):
      "return country code"
      return self.database.country_code_by_name(domain)


class CityProvider(BaseProvider):
   "Provider for the commercial MaxMind city data"

   filename = CITYDATA_FILENAME

   # Bummer! The MaxMind API does not support  this
   #def getLocationByCity(self,city):
   #   "return longitude & latitude"
   #   record = self.database.record_by_name(city)
   #   return (record["latitude"],record["longitude"])

   def getCityByIp(self,ip):
      "get city name"
      return self.database.record_by_addr(ip)["city"]

   def getCityByDomain(self, domain):
      "get city name"
      return self.database.record_by_name(domain)["city"]

   def getCountryByIp(self,ip):
      "get country code"
      return self.database.record_by_addr(ip)["country_code"]

   def getCountryByDomain(self, domain):
      "get country code"
      return self.database.record_by_name(domain)["country_code"]

   def getLocationByIp(self,ip):
      "get (latitude, longitude) tuple"
      record = self.database.record_by_addr(ip)
      return (record["latitude"],record["longitude"])

   def getLocationByDomain(self, domain):
      "get (latitude, longitude) tuple"
      record = self.database.record_by_name(domain)
      return (record["latitude"],record["longitude"])


