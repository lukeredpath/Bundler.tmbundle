#!/usr/bin/env ruby
# encoding: UTF-8

require 'ostruct'

class BundlerParser
  def self.parse(line)
    if line =~ /(Using|Installing) (.*) \((.*)\)/
      return OpenStruct.new(command: $1.downcase.to_sym, gem_name: $2, version: $3)
    end
    if line =~ /Your bundle is complete/
      return OpenStruct.new(complete?: true)
    end
  end
end

puts %Q{
<!DOCTYPE html>
<html>
  <head>
    <title>Bundler</title>
    <style type="text/css">
    body {
      margin: 0; padding: 0;
      font-family: Helvetica;
    }
    h1 {
      margin: 0; padding: 10px;
      background: #ddd;
      color: #444;
      font-size: 16px;
    }
    #output {
      padding: 10px 30px;
    }
    table {
      width: 100%;
      font-size: 14px;
      font-family: Menlo, Monaco;
    }
    td {
      border-bottom: 1px solid #ddd;
      padding: 5px 0;
    }
    td:last-child {
      color: #46a546;
    }
    a {
      color: #049cdb;
    }
    .error {
      color: #9d261d;
      font-weight: bold;
    }
    </style>
  </head>
  <body>
    <h1>Bundling Gems</h1>
    
    <div id="output">
    <table>
    <tbody>
}

ARGF.each_line do |line|
  if object = BundlerParser.parse(line)
    if object.complete?
      puts %Q{
        </tbody>
        </table>
        </div>
        </body>
        </html>
      }
    else
      puts %Q{
        <tr>
          <td><a href="http://rubygems.org/gems/#{object.gem_name}">#{object.gem_name}</a></td>
          <td>#{object.version}</td>
          <td>&check;</td>
        </tr>
      }
    end
  else
    if line =~ /Could not find gem/
      puts %Q{
        <tr>
          <td class="error" colspan="3">#{line.gsub(/\[\d+\w/, '')}</td>
        </tr>
      }
    end
  end
end
