# NAME

Business::NAB

# VERSION

0.04

# DESCRIPTION

Business::NAB is the top level namespace for the various modules
that are used to parse/create the file formats used for interchange
with NAB.

This module doesn't do anything, rather it serves to link to the
modules that you want to use.

# [Business::NAB::Types](https://metacpan.org/pod/Business%3A%3ANAB%3A%3ATypes)

Package for defining type constraints for use in the Business::NAB
namespace. All types are namespaced to "NAB::Type::\*".

# [Business::NAB::BPAY::Payments](https://metacpan.org/pod/Business%3A%3ANAB%3A%3ABPAY%3A%3APayments)

Class for parsing / creating a NAB BPAY batch payments file

# [Business::NAB::BPAY::Remittance::File](https://metacpan.org/pod/Business%3A%3ANAB%3A%3ABPAY%3A%3ARemittance%3A%3AFile)

Class for parsing / creating a NAB BPAY remittance/reporting file

# [Business::NAB::Australian::DirectEntry::Payments](https://metacpan.org/pod/Business%3A%3ANAB%3A%3AAustralian%3A%3ADirectEntry%3A%3APayments)

Class for building/parsing a "Australian Direct Entry Payments" file

# [Business::NAB::Australian::DirectEntry::Returns](https://metacpan.org/pod/Business%3A%3ANAB%3A%3AAustralian%3A%3ADirectEntry%3A%3AReturns)

Class for building/parsing a "Australian Direct Entry Payments" return file

# [Business::NAB::Australian::DirectEntry::Report](https://metacpan.org/pod/Business%3A%3ANAB%3A%3AAustralian%3A%3ADirectEntry%3A%3AReport)

Class for building/parsing a "Australian Direct Entry Payments" report file

# [Business::NAB::AccountInformation::File](https://metacpan.org/pod/Business%3A%3ANAB%3A%3AAccountInformation%3A%3AFile)

Class for parsing a NAB "Account Information File (NAI/BAI2)" file

# [Business::NAB::Acknowledgement](https://metacpan.org/pod/Business%3A%3ANAB%3A%3AAcknowledgement)

Class for parsing NAB file acknowledgements, which are XML files

# AUTHOR

Lee Johnson - `leejo@cpan.org`

# LICENSE

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself. If you would like to contribute documentation,
features, bug fixes, or anything else then please raise an issue / pull request:

```
https://github.com/payprop/business-nab
```
