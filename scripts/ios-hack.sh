#!/bin/bash
rm ios/Podfile.lock
# REPLACE: UI_USER_INTERFACE_IDIOM()
# WITH: UIDevice.current.userInterfaceIdiom
# THEN:
# flutter build ipa