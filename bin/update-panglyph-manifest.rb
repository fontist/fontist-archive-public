#!/usr/bin/env ruby
# frozen_string_literal: true

# Updates fontist-archive-public/panglyph/manifest.json with the new
# version. Idempotent: re-running with the same version is a no-op.
#
# Usage: ruby bin/update-panglyph-manifest.rb 17.0.0
#
# Adds the version to versions: if not present. Sets latest: to the
# highest semver in versions. Computes coverage summary from the
# v{X.Y.Z}/coverage-report.json if present.

require "json"
require "pathname"

if ARGV.length != 1
  warn "Usage: #{$PROGRAM_NAME} <version>"
  exit 1
end

new_version = ARGV[0]
panglyph_dir = Pathname.new("panglyph")
manifest_path = panglyph_dir.join("manifest.json")

manifest =
  if manifest_path.exist?
    JSON.parse(manifest_path.read)
  else
    { "latest" => nil, "versions" => {} }
  end

version_dir = panglyph_dir.join("v#{new_version}")
coverage_path = version_dir.join("coverage-report.json")
coverage = coverage_path.exist? ? JSON.parse(coverage_path.read) : {}

sha_paths = %i[ttf woff2 otf].each_with_object({}) do |fmt, h|
  path = version_dir.join("panglyph-unicode#{new_version.split('.').first}.#{fmt}")
  next unless path.exist?

  h[fmt.to_s] = Digest::SHA256.file(path).hexdigest
end

manifest["versions"][new_version] = {
  "ucd_version" => new_version,
  "released_at" => Time.now.utc.iso8601,
  "coverage" => {
    "covered" => coverage["covered"],
    "total" => coverage["total_codepoints"],
    "percentage" => coverage["total_codepoints"] && coverage["covered"] ?
      (coverage["covered"].to_f / coverage["total_codepoints"] * 100).round(2) : nil,
  },
  "artifacts" => {
    "ttf" => "v#{new_version}/panglyph-unicode#{new_version.split('.').first}.ttf",
    "woff2" => "v#{new_version}/panglyph-unicode#{new_version.split('.').first}.woff2",
    "otf" => "v#{new_version}/panglyph-unicode#{new_version.split('.').first}.otf",
  }.compact,
  "sha256" => sha_paths,
}

# Update latest to the highest semver
all_versions = manifest["versions"].keys
manifest["latest"] = all_versions.max_by { |v| Gem::Version.new(v) }

manifest_path.write(JSON.pretty_generate(manifest))
puts "Updated #{manifest_path}: latest=#{manifest['latest']}"
