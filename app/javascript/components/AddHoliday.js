import React from "react"
import PropTypes from "prop-types"
import { isEmpty } from "../helpers/validator";
import BaseComponent from "./BaseComponent";
import Dialog from "@material-ui/core/Dialog";
import Button from "@material-ui/core/Button";
import DialogActions from '@material-ui/core/DialogActions';
import DialogContent from '@material-ui/core/DialogContent';
import DialogContentText from '@material-ui/core/DialogContentText';
import DialogTitle from '@material-ui/core/DialogTitle';
import Typography from "@material-ui/core/Typography";
import TextField from "@material-ui/core/TextField";
import Checkbox from "@material-ui/core/Checkbox";
import FormControlLabel from "@material-ui/core/FormControlLabel";
import FormControl from "@material-ui/core/FormControl";

import { get_base_url } from "../helpers/requestHelper";

const axios = require('axios');

class AddHoliday extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            open: false,
            name: "",
            date: "",
            isGlobal: false,
            message: ""
        }
        this.toggleModalVisibility = this.toggleModalVisibility.bind(this);
        this.handleSubmitButtonClick = this.handleSubmitButtonClick.bind(this);
        this.clearMessage = this.clearMessage.bind(this);
    }

    toggleModalVisibility() {
        this.setState({ open: !this.state.open, name: "", date: "", isGlobal: false })
    }

    handleNameChange = event => {
        this.setState({ name: event.target.value });
    }

    handleDateChange = event => {
        this.setState({ date: event.target.value });
    }

    handleCheckboxChange = event => {
        this.setState({ isGlobal: event.target.checked });
    }

    handleSubmitButtonClick() {
        if (isEmpty(this.state.name)) {
            this.setState({ message: "Name can't be empty!" });
        }
        else if (isEmpty(this.state.date)) {
            this.setState({ message: "Please select a date!" });
        }
        else {

            var failureAction = (message) => {
                message = !isEmpty(message) ? message : "Failed to create a new holiday!";
                this.setState({ message: message });
            };

            const params = {
                'name': this.state.name,
                'date': this.state.date,
                'global': this.state.isGlobal.toString(),
                'api': "true"
            };

            axios({
                method: 'post',
                url: `${get_base_url()}/holidays`,
                data: params,
                headers: {
                    'content-type': 'application/json',
                }
            }).then(res => {
                if (res.data.status) {
                    this.setState({message: res.data.message});
                    this.toggleModalVisibility();
                }
                else {
                    failureAction();
                }
            }, err => {
                failureAction();
            });
    }
}

clearMessage() {
    this.setState({ message: "" });
}

render() {
    return (
        <BaseComponent message={this.state.message} handleSnackbarClosed={() => this.clearMessage()}>
            <Button variant="contained" color="primary" onClick={() => this.toggleModalVisibility()}>Create Global Holiday</Button>
            <Dialog open={this.state.open} aria-labelledby="customized-dialog-title">
                <h3 style={{background: 'white', width: '100%', maxWidth: '90%' }}>
                    Create a Holiday
                    </h3>

                <DialogContent>
                    <FormControl margin="normal">
                        <TextField required id="standard-required" label="Holiday Name" value={this.state.name} variant="outlined" placeholder="Enter name" onChange={(event) => this.handleNameChange(event)} />

                        <TextField
                            id="date"
                            label="Date of holiday"
                            type="date"
                            InputLabelProps={{
                                shrink: true,
                            }}
                            onChange={(event) => this.handleDateChange(event)}
                            value={this.state.date}
                        />

                        <FormControlLabel
                            control={
                                <Checkbox
                                    checked={this.state.isGlobal}
                                    onChange={(event) => this.handleCheckboxChange(event)}
                                    color="primary"
                                />
                            }
                            label="Is Global?"
                        />
                    </FormControl>
                </DialogContent>
                <DialogActions>
                    <Button onClick={() => this.toggleModalVisibility()} color="secondary">
                        Cancel
          </Button>

                    <Button color="primary" onClick={() => this.handleSubmitButtonClick()}>Submit Holiday</Button>
                </DialogActions>
            </Dialog>
        </BaseComponent>
    );
}
}

AddHoliday.propTypes = {
    // first_name: PropTypes.string,
    // last_name: PropTypes.string
};
export default AddHoliday
