# frozen_string_literal: true

require 'spec_helper'

describe SamlIdpMetadata::Parser do
  describe '.validate_xmlns' do
    subject { SamlIdpMetadata::Parser.call(xml: xml).validate_xmlns }

    context 'when valid xml' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid.xml')) }

      it { is_expected.to be_truthy }
    end

    context 'when invalid xml' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_invalid_xmlns.xml')) }

      it { is_expected.to be_falsey }
    end
  end

  describe '.ensure_params?' do
    subject { SamlIdpMetadata::Parser.call(xml: xml).ensure_params? }

    context 'when valid xml' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid.xml')) }

      it { is_expected.to be_truthy }
    end

    context 'when invalid xml' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_invalid.xml')) }

      it { is_expected.to be_falsey }
    end
  end

  describe 'parsed value / entity_id' do
    subject { SamlIdpMetadata::Parser.call(xml: xml).entity_id }

    context 'when valid xml' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid.xml')) }
      it { is_expected.to eq 'https://example.com/saml2/metadata/issure-url' }
    end

    context 'when valid xml w/ multiple X509Certificate (like a G Suite xml metadata)' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_gsuite.xml')) }
      it { is_expected.to eq 'https://accounts.example.com/o/saml2?idpid=xxxxxx' }
    end

    context 'when valid xml w/ sso single sign on service has 1 element. (like a SOME ONE xml metadata)' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_someone.xml')) }
      it { is_expected.to eq 'https://ap.ssso.example.com/sso/someone.example.com' }
    end

    context 'when valid xml w/ sol url not exists (like a Okta xml metadata)' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_okta.xml')) }
      it { is_expected.to eq 'http://www.example.com/someone-entity' }
    end

    context 'when invalid xml' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_invalid.xml')) }
      it { is_expected.to eq 'https://example.com/saml2/metadata/issure-url' }
    end

    context 'when invalid xml w/ entity_id is nil' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_invalid_entity_id.xml')) }
      it { is_expected.to eq nil }
    end
  end

  describe 'parsed value / sso_http_redirect_url' do
    subject { SamlIdpMetadata::Parser.call(xml: xml).sso_http_redirect_url }

    context 'when valid xml' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid.xml')) }
      it { is_expected.to eq 'https://example.com/saml2/http-redirect/sso/99999' }
    end

    context 'when valid xml w/ multiple X509Certificate (like a G Suite xml metadata)' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_gsuite.xml')) }
      it { is_expected.to eq 'https://accounts.example.com/o/saml2/idp?idpid=xxxxxx' }
    end

    context 'when valid xml w/ sso single sign on service has 1 element. (like a SOME ONE xml metadata)' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_someone.xml')) }
      it { is_expected.to eq 'https://ap.ssso.example.com/sso/someone.example.com/login' }
    end

    context 'when valid xml w/ sol url not exists (like a Okta xml metadata)' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_okta.xml')) }
      it { is_expected.to eq 'https://someone-entity.example.com/app/saml_example_app/somecode/sso/saml' }
    end

    context 'when invalid xml' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_invalid.xml')) }
      it { is_expected.to eq nil }
    end

    context 'when invalid xml w/ entity_id is nil' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_invalid_entity_id.xml')) }
      it { is_expected.to eq 'https://example.com/saml2/http-redirect/sso/99999' }
    end
  end

  describe 'parsed value / sso_http_post_url' do
    subject { SamlIdpMetadata::Parser.call(xml: xml).sso_http_post_url }

    context 'when valid xml' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid.xml')) }
      it { is_expected.to eq 'https://example.com/saml2/http-post/sso/99999' }
    end

    context 'when valid xml w/ multiple X509Certificate (like a G Suite xml metadata)' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_gsuite.xml')) }
      it { is_expected.to eq 'https://accounts.example.com/o/saml2/idp?idpid=xxxxxx' }
    end

    context 'when valid xml w/ sso single sign on service has 1 element. (like a SOME ONE xml metadata)' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_someone.xml')) }
      it { is_expected.to eq 'https://ap.ssso.example.com/sso/someone.example.com/login' }
    end

    context 'when valid xml w/ sol url not exists (like a Okta xml metadata)' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_okta.xml')) }
      it { is_expected.to eq 'https://someone-entity.example.com/app/saml_example_app/somecode/sso/saml' }
    end

    context 'when invalid xml' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_invalid.xml')) }
      it { is_expected.to eq nil }
    end

    context 'when invalid xml w/ entity_id is nil' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_invalid_entity_id.xml')) }
      it { is_expected.to eq 'https://example.com/saml2/http-post/sso/99999' }
    end
  end

  describe 'parsed value / certificate' do
    subject { SamlIdpMetadata::Parser.call(xml: xml).x509_certificate }

    context 'when valid xml' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid.xml')) }
      it { is_expected.to eq 'X509Certificate-X509Certificate=' }
    end

    context 'when valid xml w/ multiple X509Certificate (like a G Suite xml metadata)' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_gsuite.xml')) }
      it { is_expected.to eq 'Certificate001-Certificate001=' }
    end

    context 'when valid xml w/ sso single sign on service has 1 element. (like a SOME ONE xml metadata)' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_someone.xml')) }
      it { is_expected.to eq 'Certificate000-Certificate000' }
    end

    context 'when valid xml w/ sol url not exists (like a Okta xml metadata)' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_okta.xml')) }
      it { is_expected.to eq 'Certificate009=Certificate009==' }
    end

    context 'when invalid xml' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_invalid.xml')) }
      it { is_expected.to eq nil }
    end

    context 'when invalid xml w/ entity_id is nil' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_invalid_entity_id.xml')) }
      it { is_expected.to eq 'X509Certificate-X509Certificate=' }
    end
  end

  describe 'parsed value / slo_url' do
    subject { SamlIdpMetadata::Parser.call(xml: xml).slo_url }

    context 'when valid xml' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid.xml')) }
      it { is_expected.to eq 'https://example.com/saml2/http-redirect/slo/99999' }
    end

    context 'when valid xml w/ multiple singlelogout line' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_multiple_slo.xml')) }
      it { is_expected.to eq 'https://example.com/saml2/http-redirect/slo/99999' }
    end

    context 'when valid xml w/ multiple X509Certificate (like a G Suite xml metadata)' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_gsuite.xml')) }
      it { is_expected.to eq nil }
    end

    context 'when valid xml w/ sso single sign on service has 1 element. (like a SOME ONE xml metadata)' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_someone.xml')) }
      it { is_expected.to eq nil }
    end

    context 'when valid xml w/ sol url not exists (like a Okta xml metadata)' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_okta.xml')) }
      it { is_expected.to eq nil }
    end

    context 'when invalid xml' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_invalid.xml')) }
      it { is_expected.to eq nil }
    end

    context 'when invalid xml w/ entity_id is nil' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_invalid_entity_id.xml')) }
      it { is_expected.to eq 'https://example.com/saml2/http-redirect/slo/99999' }
    end
  end

  describe '.build_params' do
    subject { SamlIdpMetadata::Parser.call(xml: xml).build_params }

    context 'when valid xml' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid.xml')) }
      it {
        is_expected.to include(entity_id: 'https://example.com/saml2/metadata/issure-url',
                               sso_http_redirect_url: 'https://example.com/saml2/http-redirect/sso/99999',
                               sso_http_post_url: 'https://example.com/saml2/http-post/sso/99999',
                               certificate: 'X509Certificate-X509Certificate=',
                               slo_url: 'https://example.com/saml2/http-redirect/slo/99999',
                               metadata: xml)
      }
    end

    context 'when valid xml w/ multiple X509Certificate (like a G Suite xml metadata)' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_gsuite.xml')) }
      it {
        is_expected.to include(entity_id: 'https://accounts.example.com/o/saml2?idpid=xxxxxx',
                               sso_http_redirect_url: 'https://accounts.example.com/o/saml2/idp?idpid=xxxxxx',
                               sso_http_post_url: 'https://accounts.example.com/o/saml2/idp?idpid=xxxxxx',
                               certificate: 'Certificate001-Certificate001=',
                               slo_url: nil,
                               metadata: xml)
      }
    end

    context 'when valid xml w/ sol url not exists (like a Okta xml metadata)' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_okta.xml')) }
      it {
        is_expected.to include(entity_id: 'http://www.example.com/someone-entity',
                               sso_http_redirect_url: 'https://someone-entity.example.com/app/saml_example_app/somecode/sso/saml',
                               sso_http_post_url: 'https://someone-entity.example.com/app/saml_example_app/somecode/sso/saml',
                               certificate: 'Certificate009=Certificate009==',
                               slo_url: nil,
                               metadata: xml)
      }
    end

    context 'when valid xml w/ sso single sign on service has 1 element. (like a SOME ONE xml metadata)' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_someone.xml')) }
      it {
        is_expected.to include(entity_id: 'https://ap.ssso.example.com/sso/someone.example.com',
                               sso_http_redirect_url: 'https://ap.ssso.example.com/sso/someone.example.com/login',
                               sso_http_post_url: 'https://ap.ssso.example.com/sso/someone.example.com/login',
                               certificate: 'Certificate000-Certificate000',
                               slo_url: nil,
                               metadata: xml)
      }
    end

    context 'when invalid xml' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_invalid.xml')) }
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
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_invalid_entity_id.xml')) }
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
