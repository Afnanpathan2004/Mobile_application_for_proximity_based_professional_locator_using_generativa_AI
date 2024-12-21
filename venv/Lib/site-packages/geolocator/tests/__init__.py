import unittest

#from geolocatortests import GeolocatorTestSuite
from dummytests import DummyTestSuite
from maxmindtests import MaxMindTestSuite
from gislibtests import GislibTestSuite


__all__ = ("DummyTestSuite", "MaxMindTestSuite", "GislibTestSuite", "LibraryTestSuite", "run")

suites = (DummyTestSuite, MaxMindTestSuite, GislibTestSuite)
LibraryTestSuite = unittest.TestSuite(suites)


def run():
   "run all library tests"
   runner = unittest.TextTestRunner()
   runner.run(LibraryTestSuite)

