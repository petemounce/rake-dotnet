#!/usr/bin/env ruby

#--

# Copyright 2003, 2004, 2005, 2006, 2007, 2008, 2009 by Peter Mounce (pete@neverrunwithscissors.com)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.

#++
#
# = Rake DotNet -- A collection of custom tasks for .NET build automation
#
# This is the main file for Rake DotNet custom tasks.  Normally it is referenced
# as a library via a require statement, but it can be distributed
# independently as an application.

require 'rubygems'
gem 'rake'

require 'rake'
require 'rake/clean'
require 'rake/tasklib'
require 'Pathname'
require 'erb'
require 'rexml/document'
require 'systemu'

require 'rake_dotnet/defaults'
require 'rake_dotnet/helpers'
require 'rake_dotnet/versioner'

require 'rake_dotnet/commands/cli'
require 'rake_dotnet/commands/bcpcmd'
require 'rake_dotnet/commands/crap4ncmd'
require 'rake_dotnet/commands/fxcopcmd'
require 'rake_dotnet/commands/iisappcmd'
require 'rake_dotnet/commands/msbuildcmd'
require 'rake_dotnet/commands/ncoverconsolecmd'
require 'rake_dotnet/commands/ncoverreportingcmd'
require 'rake_dotnet/commands/ndependconsolecmd'
require 'rake_dotnet/commands/nunitcmd'
require 'rake_dotnet/commands/sevenzipcmd'
require 'rake_dotnet/commands/sqlcmd'
require 'rake_dotnet/commands/svn'
require 'rake_dotnet/commands/xunitcmd'

require 'rake_dotnet/tasks/dependenttask'
require 'rake_dotnet/tasks/assemblyinfo'
require 'rake_dotnet/tasks/crap4ntask'
require 'rake_dotnet/tasks/fxcoptask'
require 'rake_dotnet/tasks/harvestoutputtask'
require 'rake_dotnet/tasks/msbuildtask'
require 'rake_dotnet/tasks/ncovertask'
require 'rake_dotnet/tasks/ndependtask'
require 'rake_dotnet/tasks/nunittask'
require 'rake_dotnet/tasks/rdnpackagetask'
require 'rake_dotnet/tasks/xunittask'
