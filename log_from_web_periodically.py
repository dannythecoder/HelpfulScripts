#!/usr/bin/env python2
"""
log_from_web_periodically.py
 Written by Danny Caudill (DannyTheCoder).
 Apr 4, 2014

          Copyright Danny Caudill. 2014.
Distributed under the Boost Software License, Version 1.0.
   (See accompanying file LICENSE_1_0.txt or copy at
         http://www.boost.org/LICENSE_1_0.txt)

How to use:

1. Update these fields:
   - URL to retrieve
   - regex to match
   - number of regex sections to save (comma-delimited)

"""

# Imports
from __future__ import print_function
import httplib
import re
from time import sleep
import datetime


class LogFromWeb(object):
    """Log a section of a website, such as a playlist or weather site.

    Attributes:
        url (str): the address to query for content.
        regex (str): the regular expression to match against.
        regex_section_count (int): the number of sections in the regex to
        store.
        period (int): The time between successive updates (in seconds).
        debug (bool): Whether to enable extra debug features/logs.

    """

    def __init__(self,
                 new_url='www.subsonicradio.com/station/a_now_playing.php',
                 new_regex='>Now Playing.*desc.*>(.*)<.*td.*td.*'
                           'count_down_text(.*)td.*td.*Coming up',
                 new_regex_section_count=2,
                 new_period=30,
                 new_debug=False):
        """Construct this object. """
        self.url = new_url
        self.regex = new_regex
        self.regex_section_count = new_regex_section_count
        self.period = new_period
        self.debug = new_debug

    def collect_updated_site(self):
        """Get a copy of the current website.

        Returns:
            str: response from server
        """
        # Prepare the request
        index = self.url.find('/')
        hostname = self.url[:index]
        page = self.url[index:]
        if self.debug:
            print('Host: {0}  Page: {1}'.format(hostname, page))

        # Send the request and get the response
        con = httplib.HTTPConnection(hostname)
        sleep(0.5)
        con.request('GET', page)

        response = con.getresponse()
        result = response.read()

        if self.debug:
            print('=-=-=-=-=-=-=-=-\n{0} - {1}\n{2}\n=-=-=-=-=-=-=-=-'
                  ''.format(response.status,
                            response.reason,
                            result))

        return result

    def extract_sections(self, regex, input_str):
        """Extract the sections out of the site.

        Args:
            regex (str): The regular expression to match
            input_str (str): The string to match against regex

        Returns:
            List[str]: Items to log
        """
        to_log = []
        if input_str != '' and regex != '':

            if self.debug:
                print('\n*******\nRegex: {0}\ninput_str: {1}\n*******\n'
                      ''.format(regex, input_str))

            matcher = re.compile(regex)
            if matcher is None:
                raise ValueError('Invalid regular expression: {0}'
                                 ''.format(regex))

            # import pdb; pdb.set_trace()

            result = matcher.search(input_str)

            if self.debug:
                print('Regex Matches: {0}'.format(result))

            for index in xrange(self.regex_section_count):
                to_log.append(result.group(index+1))
        else:
            raise ValueError('Empty arguments passed to extract_sections.')

        return to_log

    def log_sections(self, to_log):
        """ Log a set of extracted sections

        Args:
            to_log (List[str]): List of items to log.
        """
        if self.debug:
            print('\n***** to log:')
            for val in to_log:
                print('\n{0}\n'.format(val))

        # Begin this output line
        curr = datetime.datetime.now()
        out_str = curr.isoformat(' ')
        out_str += ', '

        for val in to_log:

            # Cleanup the duration field
            if val[0] == '\\':
                val = val[17:22]

            # Store the value in the output
            out_str += val
            out_str += ', '

        print(out_str)

    def run_loop(self):
        """Run loop that periodically gets and logs updates. """
        should_continue = True

        while should_continue:
            try:
                res = self.collect_updated_site()
                to_log = self.extract_sections(self.regex, res)
                self.log_sections(to_log)
                sleep(self.period)
            except KeyboardInterrupt:
                print('Shutting down...')
                should_continue = False


def main():
    """If run as a script. """
    collector = LogFromWeb()
    collector.run_loop()
    print('Main Run Loop Exited')


if __name__ == '__main__':
    main()
