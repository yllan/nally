#!/usr/bin/env python
# Package a bundle and generate Sparkle appcasts for release

import sys, os, commands, time, plistlib, markdown2

try:
    from jinja2 import Environment, FileSystemLoader
except:
    print "Install jinja2 first."
    sys.exit(1)

def parent_url(url):
    return url[:url.rfind("/")];

def remove_if_exists(file):
    if os.path.isfile(file):
        os.remove(file)

def package_bundle(bundle_path, zip_parent):
    """Package a bundle and create the appcast, input:
    
       * A built bundle with Contents/Info.plist, must have SUFeedURL
         for Sparkle.
       * ~/.ssh/<bundleNameInLowercase>.private.pem to sign the zip"""

    plist           = plistlib.readPlist("%s/Contents/Info.plist" % bundle_path)
    bundle_name     = plist["CFBundleName"]
    appcast_url     = plist["SUFeedURL"]
    bundle_version  = plist["CFBundleVersion"]
    zip             = "%s-%s.zip" % (bundle_name, bundle_version)
    zip_url         = "%s/%s" % (zip_parent, zip)
    priv_key        = os.path.expanduser("~/.ssh/%s.private.pem" % bundle_name.lower())
    date            = time.strftime("%a, %d %b %Y %H:%M:%S %z")

    print "[PACK] Building %s..." % zip

    cwd = os.getcwd();
    os.chdir(os.path.dirname(bundle_path))
    os.system("zip -qry %s/%s %s" % (cwd, zip, os.path.basename(bundle_path)))
    os.chdir(cwd)

    print "[PACK] Signing %s..." % zip
    signed = commands.getoutput('openssl dgst -sha1 -binary < "%s" | '\
                                'openssl dgst -dss1 -sign "%s" | '\
                                'openssl enc -base64' % (zip, priv_key))

    env = Environment(loader=FileSystemLoader(sys.path[0]))
    template = env.get_template("appcast.template.xml")

    for lang in [ "en", "zh_CN", "zh_TW" ]:
        if lang == "en":
            suffix = ""
        else:
            suffix = ".%s" % lang
        relnotes = markdown2.markdown_path("Changelog%s.markdown" % suffix)
        appcast  = "%s%s.xml" % (bundle_name, suffix)
        print "[PACK] Generating %s..." % appcast
        output   = open(appcast, "w")

        output.write(template.render(appName = bundle_name,
                                     link    = appcast_url,
                                     relNotes= relnotes,
                                     url     = zip_url,
                                     date    = date,
                                     version = bundle_version,
                                     length  = os.path.getsize(zip),
                                     signed  = signed).encode("utf-8"))

        output.close()

    print "Done! Please publish %s to %s." % (zip, zip_url)

if __name__ == '__main__':
    if len(sys.argv) < 3:
        print("usage: %s <bundle> <upload path>" % sys.argv[0])
        sys.exit(1)

    package_bundle(sys.argv[1], sys.argv[2])

