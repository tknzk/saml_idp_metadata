# frozen_string_literal: true

require 'spec_helper'

describe SamlIdpMetadata::Parser do
  describe '.validate_xmlns' do
    subject { SamlIdpMetadata::Parser.call(xml: xml).validate_xmlns }

    context 'when valid xml' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_config_metadata_valid.xml')) }

      it { is_expected.to be_truthy }
    end

    context 'when invalid xml' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_config_metadata_invalid_xmlns.xml')) }

      it { is_expected.to be_falsey }
    end
  end

  describe '.ensure_params?' do
    subject { SamlIdpMetadata::Parser.call(xml: xml).ensure_params? }

    context 'when valid xml' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_config_metadata_valid.xml')) }

      it { is_expected.to be_truthy }
    end

    context 'when invalid xml' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_config_metadata_invalid.xml')) }

      it { is_expected.to be_falsey }
    end
  end

  describe '.build_params' do
    subject { SamlIdpMetadata::Parser.call(xml: xml).build_params }

    context 'when valid xml' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_config_metadata_valid.xml')) }
      it {
        is_expected.to include(entity_id: 'https://example.com/saml2/metadata/issure-url',
                               sso_http_redirect_url: 'https://example.com/saml2/http-redirect/sso/99999',
                               sso_http_post_url: 'https://example.com/saml2/http-post/sso/99999',
                               certificate: 'X509Certificate-X509Certificate=',
                               slo_url: 'https://example.com/saml2/http-redirect/slo/99999',
                               metadata: xml)
      }
    end

    context 'when valid xml w/ multiplu X509Certificate (like a G Suite xml metadata)' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_config_metadata_valid_gsuite.xml')) }
      it {
        is_expected.to include(entity_id: 'https://accounts.google.com/o/saml2?idpid=xxxxxx',
                               sso_http_redirect_url: 'https://accounts.google.com/o/saml2/idp?idpid=xxxxxx',
                               sso_http_post_url: 'https://accounts.google.com/o/saml2/idp?idpid=xxxxxx',
                               certificate: 'Certificate001-Certificate001=',
                               slo_url: nil,
                               metadata: xml)
      }
    end

    context 'when invalid xml' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_config_metadata_invalid.xml')) }
      it {
        is_expected.to include(entity_id: 'https://example.com/saml2/metadata/issure-url',
                               sso_http_redirect_url: nil,
                               sso_http_post_url: nil,
                               certificate: nil,
                               slo_url: nil,
                               metadata: xml)
      }
    end

    context 'when invalid xml' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_config_metadata_invalid_entity_id.xml')) }
      it {
        is_expected.to include(entity_id: nil,
                               sso_http_redirect_url: 'https://example.com/saml2/http-redirect/sso/99999',
                               sso_http_post_url: 'https://example.com/saml2/http-post/sso/99999',
                               certificate: 'X509Certificate-X509Certificate=',
                               slo_url: 'https://example.com/saml2/http-redirect/slo/99999',
                               metadata: xml)
      }
    end
  end
end
