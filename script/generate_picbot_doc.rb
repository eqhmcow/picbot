#!/usr/bin/env ruby

# Adapted from loudbot doc script (written by joeyk <http://spiryx.net/>)

def fix_html(ary)
  text = ""

  ary.each do |s|
    temp = s.gsub('<', '&lt;').gsub('>', '&gt;')
    temp = temp.gsub('&b', '<b>').gsub('&/b', '</b>')
    temp = temp.gsub('&i', '<i>').gsub('&/i', '</i>')

    text += "        &nbsp;&nbsp;&nbsp;&nbsp;#{temp}<br />\n"
  end

  return text
end

$commands = {
  'capture' => {
    :syntax => '&i<some image URL>&/i',
    :example => [
      "http://example.com/fluffy_mittens.jpg",
    ],
    :description => [
      "Records image URL for later mockery.",
    ],
  },

  'fetch' => {
    :syntax => '&ipicbot: <anything>&/i',
    :example => [
      "< ik> picbot: hit me",
      "< picbot> ik: http://1.media.tumblr.com/tumblr_ku9qknVvMs1qzvqipo1_400.jpg",
    ],
    :description => [
      "Fetches a random image URL.",
    ],
  },

  'whosaid' => {
    :syntax => '&iwhosaid&/i',
    :example => [
      "< picbot> ik: http://img29.imageshack.us/img29/3305/hausr.jpg",
      "< ik> picbot: whosaid",
      "< picbot> ik: bp in #mefi on irc.slashnet.org",
    ],
    :description => [
      "Tells you the nick, channel, and network the last image came from.",
    ],
  },

  'tag' => {
    :syntax => '&tag <tag>&/i',
    :example => [
      "< ik> picbot: tag nsfw",
    ],
    :description => [
      "Increments the count for the given tag on the last image said in channel",
    ],
  },
}

$template = <<EOF
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<style type="text/css">

  body
    {
      background-color: #ccc;
      font-family: sans-serif;
    }

  div.main
    {
      width: 100%;
      margin: 0px;
    }

  div.header
    {
      text-align: center;
      padding-left: 2em;
      padding-right: 8em;
      padding-bottom: 0em;
      color: #b16b16;
    }

  div.command_index
    {
      background-color: #a05a05;
      margin: 2em;
      margin-top: 0em;
      padding-top: 0em;
    }

  div.command_index ul
    {
      list-style-type: none;
      text-align: center;
      word-spacing: 20px;
    }

  div.command_index ul li
    {
      display: inline;
    }

  div.command_index a
    {
      color: #ddd;
      text-decoration: none;
      font-weight: bold;
      font-size: 14pt;
    }

  div.command_index a:hover
    {
      color: #fff;
    }

  div.command_wrapper
    {
      text-align: left;
      border: 1px solid #000;
      margin: 0em 6em 0em 8em;
      background-color: #f0f0f0;
    }

  div.command
    {
      background-color: #a05a05;
      color: #f0f0f0;
      font-weight: bold;
      display: inline;
      padding-left: 4em;
      padding-right: 4em;
      margin: 6em
    }

  div.description
    {
      background-color: #f0f0f0;
      color: #555;
      font-weight: normal;
      padding-left: 1em;
    }

  div.description h3
    {
      display: inline;
    }

  div.space
    {
      margin: 3em;
    }

</style>

<title>picbot v0.1 Documentation</title>
<meta http-equiv="content-type" content="text/html; charset=utf-8" />

</head>
<body>
  <div class="main">
    <div class="header"><h1>picbot v0.1 Documentation</h1></div>
    <div class="command_index">
      <ul>
        <li><a href="#capture">capture</a></li>
        <li><a href="#fetch">fetch</a></li>
        <li><a href="#tag">tag</a></li>
        <li><a href="#whosaid">whosaid</a></li>
      </ul>
    </div>
EOF

puts $template
$commands.sort.each do |cmd, info|
  puts <<-EOF
    <!-- command: #{cmd} -->
    <div class="command_wrapper" id="div_#{cmd}">
      <div class="command"><a name="#{cmd}">#{cmd}</a></div>
      <div class="description"><br /><br />
        <h3>Syntax:</h3><br />
#{fix_html(info[:syntax])}
        <br />
        <h3>Description:</h3><br />
#{fix_html(info[:description])}
        <br />
        <h3>Example:</h3><br />
#{fix_html(info[:example])}
        <br />
      </div>
    </div><!-- #{cmd} -->

    <div class="space"></div>

  EOF
end

puts <<EOF
  </div>
</body>
</html>
EOF
