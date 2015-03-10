
Pod::Spec.new do |s|

  s.name         = "BMACollectionViewLayouts"
  s.version      = "1.0.0"
  s.summary      = "A set of UICollectionViewLayout subclasses"

  s.description  = <<-DESC
                   A set of useful UICollectionViewLayout subclasses that many apps may need some time.

                   There is one layout at the moment, but more are coming.

                   Layouts included:

                   - BMAReorderableFlowLayout: A UICollectionViewFlowLayout subclass allowing the user to reorder the elements by tap+hold and dragging
                   the views around. From code point of view it allows you to customise the look and feel of the cell and collection view, as well as giving callbacks about
                   the reordering itself.

                   DESC

  s.homepage     = "http://github.com/badoo/BMACollectionViewLayouts"
  s.license      = { :type => "MIT" }
  s.author       = { "Miguel Angel Quinones" => "m.quinones.garcia@gmail.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/badoo/BMACollectionViewLayouts", :tag => s.version.to_s }
  s.source_files  = "BMACollectionViewLayouts/**/*.{h,m}"
  s.public_header_files = "BMACollectionViewLayouts/**/*.h"
  s.requires_arc = true

end
