module Jekyll
  class CopyRoot < StaticFile
    def destination(dest)
      File.join(dest, @name)
    end
  end
  class Index < Generator
    def generate(site)
      site.static_files << CopyRoot.new(site, site.source, '_site/docs/introduction', 'index.html')
    end
  end
end
