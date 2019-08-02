# ![Twilio Logo](../assets/twilio-small.png "Twilio") Twilio

<!-- toc -->

## Features

[Twilio](https://www.twilio.com) is a third party service that provides programmable SMS and Voice telephone services. Via its REST API's and Webhooks you can [receive and place phone calls](https://www.twilio.com/voice), use NLP API's to process voice input, send computer generated responses in addition to [send and receive text messages](https://www.twilio.com/sms). [Twilio](https://www.twilio.com) works with a global set of carriers, and gives you a real phone number to use for incoming and outgoing interactions from any nation or to any phone number. 

Twilio also offers services such as programmable wireless, a service where SIM cards on various networks can be activated via programmatic REST interfaces, in addition it provides direct M2M API access.

## Plans

|                  | Small       | Medium     | Large        |
|------------------|-------------|------------|--------------|
| Price            | $50/mon     | $100/mon   | $200/mon     |
| Voice Minutes    | 2500        | 5000       | 10,000       |
| SMS Messages     | 3000        | 6000       | 12,000       |
| M2M Messages     | 1000        | 2000       | 4,000        |
| Dedicated Phone  | Yes         | Yes        | Yes          |
| SIM Limit        | 40          | 80         | 160          |

**IMPORTANT SIM Cards:** Physical SIM cards (if needed) can be purchased through the Twilio API. For physical SIM cards a limit is in place to prevent provisioning more than your plan may allow. Additional costs ($40/mon + $5 per SIM card) apply, the SIM cards are shipped to your administrators address on file with Twilio. Physical SIM cards are not necessary for using the Twilio API.

**IMPORTANT SendGrid Features:** Sending emails via SendGrid through Twilio's API's are not supported. 

### Provisioning the add-on

```
aka addons:create twilio:small -a [app-space]
```

Once provisioned this will add the environment variables `TWILIO_AUTH_TOKEN` which contains the authorization token for twilio, `TWILIO_PHONE_NUMBER` which contains the provisioned phone number in the format of `+(international code)(area code)(local code)` e.g., `+18015556666` and `TWILIO_SID` which contains the account number.  All interactions can be done via the REST API, if a console account is needed for reporting or administration needs please contact your administrator who can generate an account.