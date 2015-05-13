# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Copyright 2015 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

from autopilot.matchers import Eventually
from testtools.matchers import Equals

from webbrowser_app.tests import StartOpenRemotePageTestCaseBase


class TestFindInPage(StartOpenRemotePageTestCaseBase):

    """Tests the find in page functionality."""

    def setUp(self):
        super().setUp()
        self.chrome = self.main_window.chrome
        self.url = self.base_url + "/findinpage"

    def activate_find_in_page(self, navigateFirst=True):
        if navigateFirst:
            self.main_window.go_to_url(self.url)
            self.main_window.wait_until_page_loaded(self.url)

        drawer_button = self.chrome.get_drawer_button()
        self.pointing_device.click_object(drawer_button)
        self.chrome.get_drawer()
        action = self.chrome.get_drawer_action("findinpage")
        self.pointing_device.click_object(action)

    def test_activation(self):
        next = self.chrome.get_find_next_button()
        prev = self.chrome.get_find_prev_button()
        bar = self.chrome.address_bar
        counter = bar.get_find_in_page_counter()

        self.assertThat(bar.findInPageMode, Equals(False))
        self.assertThat(next.visible, Equals(False))
        self.assertThat(prev.visible, Equals(False))
        self.assertThat(counter.visible, Equals(False))

        self.activate_find_in_page(False)
        self.assertThat(bar.findInPageMode, Eventually(Equals(True)))
        self.assertThat(next.visible, Eventually(Equals(True)))
        self.assertThat(prev.visible, Eventually(Equals(True)))
        self.assertThat(counter.visible, Eventually(Equals(True)))

        self.assertThat(self.chrome.is_back_button_enabled(), Equals(True))
        self.assertThat(self.chrome.is_forward_button_enabled(), Equals(False))
        self.chrome.go_back()

        self.assertThat(bar.findInPageMode, Eventually(Equals(False)))
        self.assertThat(next.visible, Eventually(Equals(False)))
        self.assertThat(prev.visible, Eventually(Equals(False)))
        self.assertThat(counter.visible, Eventually(Equals(False)))

    def test_counter(self):
        bar = self.chrome.address_bar
        counter = bar.get_find_in_page_counter()

        self.activate_find_in_page()
        bar.write("text")
        self.assertThat(counter.current, Eventually(Equals(1)))
        self.assertThat(counter.count, Eventually(Equals(2)))

        bar.write("hello")
        self.assertThat(counter.current, Eventually(Equals(1)))
        self.assertThat(counter.count, Eventually(Equals(1)))

        bar.write("")
        self.assertThat(counter.current, Eventually(Equals(0)))
        self.assertThat(counter.count, Eventually(Equals(0)))

    def test_minimum_two_characters(self):
        bar = self.chrome.address_bar
        counter = bar.get_find_in_page_counter()

        self.activate_find_in_page()
        bar.write("t")
        self.assertThat(counter.current, Eventually(Equals(0)))
        self.assertThat(counter.count, Eventually(Equals(0)))

        bar.write("e", False)
        self.assertThat(counter.current, Eventually(Equals(1)))
        self.assertThat(counter.count, Eventually(Equals(2)))

    def test_navigation(self):
        bar = self.chrome.address_bar
        counter = bar.get_find_in_page_counter()
        next = self.chrome.get_find_next_button()
        prev = self.chrome.get_find_prev_button()

        self.activate_find_in_page()
        self.assertThat(next.enabled, Eventually(Equals(False)))
        self.assertThat(prev.enabled, Eventually(Equals(False)))

        bar.write("text")
        self.assertThat(next.enabled, Eventually(Equals(True)))
        self.assertThat(prev.enabled, Eventually(Equals(True)))

        self.pointing_device.click_object(next)
        self.assertThat(counter.current, Eventually(Equals(2)))
        self.assertThat(counter.count, Eventually(Equals(2)))
        self.pointing_device.click_object(next)
        self.assertThat(counter.current, Eventually(Equals(1)))
        self.assertThat(counter.count, Eventually(Equals(2)))
        self.pointing_device.click_object(prev)
        self.assertThat(counter.current, Eventually(Equals(2)))
        self.assertThat(counter.count, Eventually(Equals(2)))
        self.pointing_device.click_object(next)
        self.assertThat(counter.current, Eventually(Equals(1)))
        self.assertThat(counter.count, Eventually(Equals(2)))

        bar.write("hello")
        self.assertThat(next.enabled, Eventually(Equals(False)))
        self.assertThat(prev.enabled, Eventually(Equals(False)))
