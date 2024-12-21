"""
Base (dummy) providers

"""

import os, sys

class CityDataProvider:

   def getCityByIp(self, ip):
      "get city name"
      klass, func = self.__class__.__name__, sys._getframe().f_code.co_name
      raise NotImplementedError("%s is not implemented by %s." % (func, klass))

   def getCityByDomain(self, domain):
      "get city name"
      klass, func = self.__class__.__name__, sys._getframe().f_code.co_name
      raise NotImplementedError("%s is not implemented by %s." % (func, klass))

   #def getLocationByCity(self, city):
   #   "get (latitude, longitude) tuple"
   #   klass, func = self.__class.__name__, sys._getframe().f_code.co_name
   #   raise NotImplementedError("%s is not implemented by %s." % (func, klass))

   #def locateCity(self, city):
   #   "get (latitude, longitude) tuple"
   #   klass, func = self.__class.__name__, sys._getframe().f_code.co_name
   #   raise NotImplementedError("%s is not implemented by %s." % (func, klass))

   #def getTimeZoneByCity(self, city):
   #   "return time zone code"
   #   klass, func = self.__class.__name__, sys._getframe().f_code.co_name
   #   raise NotImplementedError("%s is not implemented by %s." % (func, klass))


class LocationDataProvider:
   "get coordinates"

   def getLocationByIp(self, ip):
      "get country code"
      klass, func = self.__class__.__name__, sys._getframe().f_code.co_name
      raise NotImplementedError("%s is not implemented by %s." % (func, klass))

   def getLocationByDomain(self, domain):
      "get country code"
      klass, func = self.__class__.__name__, sys._getframe().f_code.co_name
      raise NotImplementedError("%s is not implemented by %s." % (func, klass))


class CountryDataProvider:
   "get country"

   def getCountryByIp(self, ip):
      "get country code"
      klass, func = self.__class__.__name__, sys._getframe().f_code.co_name
      raise NotImplementedError("%s is not implemented by %s." % (func, klass))

   def getCountryByDomain(self, domain):
      "get country code"
      klass, func = self.__class__.__name__, sys._getframe().f_code.co_name
      raise NotImplementedError("%s is not implemented by %s." % (func, klass))

   #def getLocationByCountry(self,countrycode):
   #   "get (latitude, longitude) tuple"
   #   klass, func = self.__class.__name__, sys._getframe().f_code.co_name
   #   raise NotImplementedError("%s is not implemented by %s." % (func, klass))

   #def locateCountry(self, countrycode):
   #   "get (latitude, longitude) tuple"
   #   klass, func = self.__class.__name__, sys._getframe().f_code.co_name
   #   raise NotImplementedError("%s is not implemented by %s." % (func, klass))


class Provider(CountryDataProvider, CityDataProvider, LocationDataProvider):
   "a dummy provider to be used when none can be used"






